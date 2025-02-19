
/**
 * A server for the game.
 * 
 * @param {Struct.NetworkServer} networkServer The underlying server controller on the network.
 */
function Server(networkServer) constructor {
	
	CLASS_LOG;
	
	self.jsonRpc = new JsonRpc(ServerProcedures.procedureList, ClientProcedures.procedureList);
	self.clients = [];
	
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
	 * @param {Id.Socket} client The client to call the procedure on.
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static call = function(client, procedure, params, callback) {
		self.networkServer.sendJson(client, self.jsonRpc.createRequest(procedure, params, callback));
	};
	
	/**
	 * Respond to a remote procedure call from the given client, with the specified response data.
	 * 
	 * @private
	 * @param {Id.Socket} client The client to reply to.
	 * @param {Struct.JsonRpcIncomingRequest} request The request for which we are responding to.
	 * @param {Struct.Message} response The response data to send.
	 */
	static respond = function(client, request, response) {
		self.networkServer.sendJson(client, self.jsonRpc.createResponse(request, response));
	};
	
	/**
	 * Send pings to connected players periodically.
	 * If a client has not responded for too long, the server will consider them to have lost connection.
	 * 
	 * TODO: Currently, this means they are dropped. Once the RTS & Lockstep system develops, this behaviour will change.
	 * 
	 * @private
	 */
	static sendHeartbeatPings = function() {
		array_foreach(self.clients, function(client) {
			self.call(client, ClientProc.heartbeat, new ClientHeartbeatRequest(), function() {
				log.debug("FIXME: no-op heartbeat reply");
			});
		});
	};
	
	/**
	 * Handle a client's connection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onNetConnect = function(client) {
		log.info($"New connection from `{client}`");
		array_push(self.clients, client);
	};
	
	/**
	 * Handle a client's disconnection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onNetDisconnect = function(client) {
		log.debug($"`{client}` is disconnecting");
		array_delete(self.clients, array_get_index(self.clients, client), 1);
	};
	
	/**
	 * Handle incoming data from a client.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 * @param {Id.Buffer} buffer
	 */
	static onNetData = function(client, buffer) {
		
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Packet from client `{client}`: `{text}`");
		
		try {
			json = json_parse(text);
		} catch (_) {
			log.error(new Err("TODO: Failed to parse inbound message from client!"));
			return;
		}
		
		var request;
		
		try {
			request = self.jsonRpc.handleIncoming(json);
		} catch (err) {
			log.error(new Err("Error whilst handling incoming request", err));
			return;
		}
		
		if (!is_instanceof(request, JsonRpcIncomingRequest)) {
			return;
		}
		
		var procedureHandler = procedureHandlers[$ request.procedure.name];
		procedureHandler(client, request, request.params);
		
	};
	
	/**
	 * @param {Id.Socket} client
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.ServerJoinRequest} params
	 */
	static onJoin = function(client, request, params) {
		
		var desiredUsername = params.desiredUsername;
		log.info($"Client `{client}` joining with username {desiredUsername}");
		
		self.respond(client, request, new ServerJoinResponse(
			client,
			self.clients
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
