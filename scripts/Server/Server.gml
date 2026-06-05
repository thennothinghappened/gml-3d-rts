
/**
 * A server for the game.
 * 
 * @param {Struct.NetworkServer} _networkServer The underlying server controller on the network.
 */
function Server(_networkServer) constructor {
	CLASS_LOG;
	
	jsonRpc = new JsonRpc(ServerProc, ClientProc);
	
	/**
	 * @type {Array<Id.Socket, Struct.Server_ClientInterface|Undefined>}
	 */
	clients = [];
	FEATHERHINT { clients[0] = new Server_ClientInterface(self, 0, "") }
	
	/**
	 * List of sockets which have connected but haven't yet completed the handshake to become a client.
	 * @type {Array<Id.Socket>}
	 */
	socketsAwaitingHandshake = [];
	
	networkServer = _networkServer;
	
	/**
	 * Timer that runs indefinitely whilst the server is up, sending heartbeat pings to clients.
	 */
	heartbeatTimer = time_source_create(
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
		if (!networkServer.listen()) {
			return false;
		}
		
		time_source_start(heartbeatTimer);
		return true;
	}
	
	/**
	 * Dispose of this server.
	 * This method **MUST** be called to clean up the resources used by this server.
	 */
	static dispose = function() {
		time_source_destroy(heartbeatTimer);
		networkServer.dispose();
	}
	
	/**
	 * Get the client interface for the client with the provided socket ID.
	 * 
	 * Returns `undefined` if that client is not connected/has not completed the handshake.
	 * 
	 * @pure
	 * @param {Id.Socket} clientId
	 * @returns {Struct.Server_ClientInterface} Can be `undefined` but feather doesn't like that :/
	 */
	static getClient = function(clientId) {
		if (array_length(clients) <= clientId) {
			return undefined;
		}
		
		var client = clients[clientId];
		
		if (!is_instanceof(client, Server_ClientInterface)) {
			return undefined;
		}
		
		return client;
	}
	
	/**
	 * Run a callback for each connected client.
	 * 
	 * @param {Function} callback `(Struct.Server_ClientInterface) -> Undefined`
	 */
	static forEachClient = function(callback) {
		for (var i = 0; i < array_length(clients); i ++) {
			var client = getClient(i);
			
			if (client != undefined) {
				callback(client);
			}
		}
	}
	
	/**
	 * Call a remote procedure on a given client.
	 * 
	 * @private
	 * @param {Id.Socket} client The client to call the procedure on.
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static sendRequest = function(client, procedure, params, callback) {
		networkServer.sendJson(client, jsonRpc.createRequest(procedure, params, callback));
	}
	
	/**
	 * Send a notification to a client without expecting a response.
	 * 
	 * @private
	 * @param {Id.Socket} client
	 * @param {Struct.JsonRpcProcedure} procedure
	 * @param {Struct.Message} params
	 */
	static sendNotification = function(client, procedure, params) {
		networkServer.sendJson(client, jsonRpc.createNotification(procedure, params));
	}
	
	/**
	 * Respond to a remote procedure call from the given client, with the specified response data.
	 * 
	 * @private
	 * @param {Id.Socket} client The client to reply to.
	 * @param {Struct.JsonRpcIncomingRequest} request The request for which we are responding to.
	 * @param {Struct.Message} response The response data to send.
	 */
	static sendResponse = function(client, request, response) {
		networkServer.sendJson(client, jsonRpc.createResponse(request, response));
	}
	
	/**
	 * Send pings to connected players periodically.
	 * If a client has not responded for too long, the server will consider them to have lost connection. (TODO)
	 * 
	 * @private
	 */
	static sendHeartbeatPings = function() {
		//forEachClient(function(client) {
			//client.heartbeat(new S2C_Heartbeat(), function() {
				//log.debug("FIXME: no-op heartbeat reply");
			//});
		//});
	}
	
	#region Network event handlers
	
	/**
	 * Handle a client's connection.
	 * 
	 * @ignore
	 * @param {Id.Socket} clientId
	 */
	networkServer.events.on("connect", function(clientId) {
		log.info($"New connection from `{clientId}`, awaiting handshake.");
		array_push(socketsAwaitingHandshake, clientId);
	});
	
	/**
	 * Handle a client's disconnection.
	 * 
	 * @ignore
	 * @param {Id.Socket} clientId
	 */
	networkServer.events.on("disconnect", function(clientId) {
		// If they've not yet joined properly, we can ignore that socket now.
		var awaitingHandshakeIndex = array_get_index(socketsAwaitingHandshake, clientId);
		
		if (awaitingHandshakeIndex >= 0) {
			array_delete(socketsAwaitingHandshake, awaitingHandshakeIndex, 1);
			log.debug($"Client {clientId} has given up on joining.");
			
			return;
		}
		
		// Actual client disconnection!
		log.info($"Player {clients[clientId].username} has left the server.");
		clients[clientId] = undefined;
		
		// Cull any other empty entries.
		for (var i = array_length(clients) - 1; i >= 0; i --) {
			if (getClient(i) == undefined) {
				array_resize(clients, i);
			}
		}
	});
	
	/**
	 * Handle incoming data from a client.
	 * 
	 * @ignore
	 * @param {Id.Socket} clientId
	 * @param {Id.Buffer} buffer
	 */
	networkServer.events.on("data", function(clientId, buffer) {
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Packet from client `{clientId}`: `{text}`");
		
		try {
			json = json_parse(text);
		} catch (_) {
			log.error(new Err("TODO: Failed to parse inbound message from client!"));
			return;
		}
		
		var request;
		
		try {
			request = jsonRpc.handleIncoming(json);
		} catch (err) {
			log.error(new Err("Error whilst handling incoming request", err));
			return;
		}
		
		if (!is_instanceof(request, JsonRpcIncomingRequest)) {
			return;
		}
		
		var client = getClient(clientId);
		
		if (client == undefined) {
			// Their request *must* be the handshake, or we ought to boot this misbehaving client.
			if (request.procedure != ServerProc.join) {
				// TODO: Send an error response.
				log.warn($"Misbehaving client (ID {clientId}) attempted to call RPC method {request.procedure.name} before completing the handshake.");
				return;
			}
			
			return onJoin(clientId, request, request.params);
		}
		
		var procedureHandler = procedureHandlers[$ request.procedure.name];
		procedureHandler(client, request, request.params);
	});
	
	#endregion
	#region RPC request handlers
	
	/**
	 * Validate a new player's attempt to join the server, finishing the handshake if the request succeeded.
	 * 
	 * This is a special RPC event which is handled separately as it needs to complete the join handshake.
	 * 
	 * @param {Id.Socket} clientId
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.C2S_ConnectBeginHandshake} params
	 */
	static onJoin = function(clientId, request, params) {
		Assert.cond(
			array_delete_first(socketsAwaitingHandshake, clientId),
			"Client should've been in the no-handshake list upon being added"
		);
		
		var desiredUsername = params.desiredUsername;
		var client = new Server_ClientInterface(self, clientId, desiredUsername);
		
		forEachClient(method(new S2C_OtherPlayerJoined(client.id, client.username), function(otherClient) {
			otherClient.otherPlayerJoined(self);
		}));
		
		clients[clientId] = client;
		log.info($"{desiredUsername} has joined the server.");
		
		var clientList = [];
		
		forEachClient(method({ clientList }, function(otherClient) {
			array_push(clientList, {
				id: otherClient.id,
				username: otherClient.username
			});
		}));
		
		client.sendResponse(request, new S2C_ConnectSuccess(client.id, clientList));
	}
	
	/**
	 * A misbehaving client who is already in the lobby has sent an additional join request.
	 * 
	 * @param {Struct.Server_ClientInterface} client
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.C2S_ConnectBeginHandshake} params
	 */
	static onRepeatedJoinRequest = function(client, request, params) {
		log.warn($"Misbehaving Client: {client.username} has sent another join request when they're already connected.'");
	}
	
	/**
	 * A player wishes to send a chat message.
	 * 
	 * @param {Struct.Server_ClientInterface} client
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.C2S_ChatMessage} params
	 */
	static onSendChatMessage = function(client, request, params) {
		var notification = new S2C_ChatMessageAdded(client.id, params.visibility, params.message);
		
		// mildly cursed, give us closures yoyo!!!!!!
		forEachClient(method(notification, function(client) {
			client.addChatMessage(self);
		}));
	}
	
	#endregion
	
	/**
	 * List of registered handlers for procedures on the server.
	 * @ignore
	 */
	static procedureHandlers = {};
	
	if (struct_names_count(procedureHandlers) == 0) {
		procedureHandlers[$ ServerProc.join.name] = onRepeatedJoinRequest;
		procedureHandlers[$ ServerProc.sendChatMessage.name] = onSendChatMessage;
		
		// Ensure all procedures have been registered.
		Assert.eq(struct_get_names(procedureHandlers), struct_get_names(ServerProc));
	}
}

/**
 * Interface for the server to interact with a given client in a well-defined way.
 * 
 * @ignore
 * @param {Struct.Server} _server
 * @param {Id.Socket} _id
 * @param {String} _username
 */
function Server_ClientInterface(_server, _id, _username) constructor {
	/**
	 * @ignore
	 */
	server = _server;
	
	id = _id;
	username = _username;
	
	/**
	 * @param {Struct.S2C_Heartbeat} params
	 * @param {Function} callback
	 */
	static heartbeat = function(params, callback) {
		server.sendRequest(id, ClientProc.heartbeat, params, callback);
	}
	
	/**
	 * @param {Struct.S2C_OtherPlayerJoined} params
	 */
	static otherPlayerJoined = function(params) {
		server.sendNotification(id, ClientProc.otherPlayerJoined, params);
	}
	
	/**
	 * @param {Struct.S2C_AddChatMessage} params
	 */
	static addChatMessage = function(params) {
		server.sendNotification(id, ClientProc.addChatMessage, params);
	}
	
	/**
	 * Respond to this client's RPC message with some data.
	 * 
	 * @param {Struct.JsonRpcIncomingRequest} request The request we're responding to.
	 * @param {Struct.Message} response The data to send.
	 */
	static sendResponse = function(request, response) {
		server.sendResponse(id, request, response);
	}
}
