
/**
 * A server for the game.
 * 
 * @param {Struct.NetworkServer} networkServer The underlying server controller on the network.
 */
function Server(networkServer) constructor {
	
	CLASS_LOG;
	
	self.jsonRpc = new JsonRpc(ServerProc.procedureList, ClientProc.procedureList);
	
	/**
	 * List of players connected to the server, in join (handshake) order.
	 * 
	 * A player is added to this list once it has completed the connection handshake with the server.
	 */
	self.players = [];
	
	/**
	 * Map of client network (socket) IDs to the respective players.
	 * @type {Record<Id.Socket, Struct.RemotePlayer>}
	 */
	self.playerSocketIdMap = {};
	
	/**
	 * Map of current outbound procedure call IDs to the respective clients for which they were called on.
	 * @type {Record<Id.Socket, Array<Real>>}
	 */
	self.clientOutboundCallMap = {};
	
	self.networkServer = networkServer;
	self.networkServer.events.on("connect", method(self, self.onNetConnect));
	self.networkServer.events.on("disconnect", method(self, self.onNetDisconnect));
	self.networkServer.events.on("data", method(self, self.onNetData));
	
	/**
	 * Timer that runs indefinitely whilst the server is up, sending heartbeat pings to clients.
	 */
	self.heartbeatTimer = time_source_create(
		time_source_game, (HEARTBEAT_MESSAGE_INTERVAL_MILLISECONDS / 1000), time_source_units_seconds,
		method(self, self.sendHeartbeatPings), [],
		-1
	);
	
	/**
	 * Begins listening on the network for clients.
	 * Returns whether the operation was successful.
	 * 
	 * @returns {Bool}
	 */
	static listen = function() {
		
		if (!self.networkServer.listen()) {
			return false;
		}
		
		time_source_start(self.heartbeatTimer);
		return true;
		
	}
	
	/**
	 * Dispose of this server.
	 * This method **MUST** be called to clean up the resources used by this server.
	 */
	static dispose = function() {
		time_source_destroy(self.heartbeatTimer);
		self.networkServer.dispose();
	};
	
	/**
	 * Call a remote procedure on a given client.
	 * 
	 * @private
	 * @param {Struct.RemotePlayer|Id.Socket} player The player to call the procedure on.
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static call = function(player, procedure, params, callback) {
		
		var socketId = (is_instanceof(player, RemotePlayer) ? player.socketId : player);
		var request = self.jsonRpc.createRequest(procedure, params, callback);
		
		array_push(self.clientOutboundCallMap[$ socketId], request.id);
		self.networkServer.sendJson(socketId, request);
		
		return request;
		
	};
	
	/**
	 * Respond to a remote procedure call from the given client, with the specified response data.
	 * 
	 * @private
	 * @param {Struct.RemotePlayer|Id.Socket} player The player to reply to.
	 * @param {Struct.JsonRpcIncomingRequest} request The request for which we are responding to.
	 * @param {Struct.Message} response The response data to send.
	 */
	static respond = function(player, request, response) {
		var socketId = (is_instanceof(player, RemotePlayer) ? player.socketId : player);
		self.networkServer.sendJson(player.socketId, self.jsonRpc.createResponse(request, response));
	};
	
	/**
	 * Respond with an error to a remote procedure call from the given client, with the specified error information.
	 * 
	 * @private
	 * @param {Struct.RemotePlayer} player The player to reply to.
	 * @param {Struct.JsonRpcIncomingRequest|Undefined} request The request for which we are responding to. This may not be known if the request failed to parse.
	 * @param {Struct.JsonRpcError} error The error to respond with.
	 */
	static respondError = function(player, request, error) {
		self.networkServer.sendJson(player.socketId, self.jsonRpc.createErrorResponse(request, error));
	};
	
	/**
	 * Send pings to connected players periodically.
	 * If a client has not responded for too long, the server will consider them to have lost connection.
	 * 
	 * @private
	 */
	static sendHeartbeatPings = function() {
		array_foreach(self.players, function(player) {
			
			if (player.unacknowledgedHeartbeats > HEARTBEAT_MESSAGE_MAX_MISS_COUNT) {
				return self.onConnectionLost(player);
			}
			
			player.unacknowledgedHeartbeats ++;
			
			self.call(player, ClientProc.heartbeat, new ClientHeartbeatRequest(), method({ player }, function() {
				player.unacknowledgedHeartbeats --;
			}));
			
		});
	};
	
	/**
	 * Called upon an unintended loss of connection to the given player.
	 * 
	 * TODO: Currently we treat disconnection as final - re-joining should ideally be possible!
	 * 
	 * @param {Struct.RemotePlayer} player
	 */
	static onConnectionLost = function(player) {
		self.forgetPlayer(player);
		self.forgetClientRequests(player.socketId);
	}
	
	/**
	 * Forget all outbound calls to the given client, since they've disconnected.
	 * 
	 * @param {Id.Socket} socketId ID of the socket of the client.
	 */
	static forgetClientRequests = function(socketId) {
		if (struct_exists(self.clientOutboundCallMap, string(socketId))) {
			array_foreach(self.clientOutboundCallMap[$ socketId], self.jsonRpc.forgetRequest);
			delete self.clientOutboundCallMap[$ socketId];
		}
	};
	
	/**
	 * Drop the given player from the server.
	 * 
	 * @param {Struct.RemotePlayer} player
	 */
	static forgetPlayer = function(player) {
		
		log.debug($"Dropping the player `{player.username}` from the server.");
		
		array_delete(self.players, array_get_index(self.players, player), 1);
		delete self.playerSocketIdMap[$ player.socketId];
		
	};
	
	/**
	 * Handle a client's connection.
	 * 
	 * @ignore
	 * @param {Id.Socket} socketId
	 */
	static onNetConnect = function(socketId) {
		
		log.info($"New connection from `{socketId}`");
		self.clientOutboundCallMap[$ socketId] = [];
		
	};
	
	/**
	 * Handle disconnection of the given client socket.
	 * 
	 * @ignore
	 * @param {Id.Socket} socketId
	 */
	static onNetDisconnect = function(socketId) {
		
		log.debug($"`{socketId}` has disconnected.");
		self.forgetClientRequests(socketId);
		
		var player = self.playerSocketIdMap[$ socketId];
		
		if (!is_undefined(player)) {
			self.onConnectionLost(player);
		}
		
	};
	
	/**
	 * Handle incoming data from a client.
	 * 
	 * @ignore
	 * @param {Id.Socket} socketId
	 * @param {Id.Buffer} buffer
	 */
	static onNetData = function(socketId, buffer) {
		
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Packet from client `{socketId}`: `{text}`");
		
		var player = self.playerSocketIdMap[$ socketId];
		
		if (is_undefined(player)) {
			
			// We should only be here if the handshake has not completed yet, as such there should be no player
			// associated in the players array yet.
			Assert.cond(array_all(self.players, method({ socketId }, function(player) {
				return (player.socketId != socketId);
			})));
			
			// Create a "partial" player object which only has a socket ID.
			player = new RemotePlayer(socketId, "", "");
			
		}
		
		try {
			json = json_parse(text);
		} catch (_) {
			log.error($"Client `{player.socketId}` sent malformed JSON.");
			return self.respondError(player, undefined, new JsonRpcError(JsonRpcErrorCode.Parse, "Malformed request JSON"));
		}
		
		var request;
		
		try {
			request = self.jsonRpc.handleIncoming(json);
		} catch (err) {
			
			log.error($"Error handling request: {err}");
			
			if (is_instanceof(err, JsonRpcError)) {
				self.respondError(player, undefined, err);
			}
			
			return;
		}
		
		if (!is_instanceof(request, JsonRpcIncomingRequest)) {
			return;
		}
		
		try {
			
			var procedureHandler = procedureHandlers[$ request.procedure.name];
			procedureHandler(player, request, request.params);
			
		} catch (err) {
			
			log.error($"Internal error in procedure `{request.procedure.name}`: {err}");
			self.respondError(player, request, new JsonRpcError(JsonRpcErrorCode.InternalError, "An internal error occurred"));
			
		}
		
	};
	
	/**
	 * Called by clients to complete the handshake with the server to join it.
	 * 
	 * Once the handshake is complete, clients are registered in the appropriate locations.
	 * 
	 * @param {Struct.RemotePlayer} partialPlayer
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.ServerJoinRequest} params
	 */
	static onJoin = function(partialPlayer, request, params) {
		
		var uuid = params.uuid;
		var username = params.desiredUsername;
		
		// If the UUID is taken, something fishy is afoot and this player should be rejected.
		if (array_any(self.players, method({ uuid }, function(player) {
			return (player.uuid == uuid);
		}))) {
			
			// TODO: same UUID would actually indicate intent to rejoin, if we've lost connection to them.
			log.warn($"Rejecting player with UUID `{uuid}` and desired username {username} as this UUID is already in use by another player.");
			
			return self.respondError(partialPlayer, request, new JsonRpcError(
				JsonRpcErrorCode.InvalidRequest,
				"A player with your UUID is already in the server!"
			));
			
		}
		
		// Crude method of ensuring unique usernames!
		while (array_any(self.players, method({ username }, function(player) {
			return (player.username == username);
		}))) {
			username += "1";
		}
		
		var playerList = array_map(self.players, function(player) {
			return new PlayerDetails(player.uuid, player.username);
		});
		
		var player = new RemotePlayer(partialPlayer.socketId, uuid, username);
		
		array_push(self.players, player);
		self.playerSocketIdMap[$ player.socketId] = player;
		
		log.info($"`{player.username}` is joining the game.");
		
		self.respond(player, request, new ServerJoinResponse(
			username,
			playerList
		));
		
	};
	
	/**
	 * List of registered handlers for procedures on the server.
	 * @ignore
	 */
	static procedureHandlers = {};
	
	if (struct_names_count(procedureHandlers) == 0) {
		
		procedureHandlers[$ ServerProc.join.name] = self.onJoin;
		
		// Ensure all procedures have been registered.
		Assert.eq(struct_names_count(procedureHandlers), array_length(ServerProc.procedureList));
		
	}
	
}
