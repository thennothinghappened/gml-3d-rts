
/**
 * A game client!
 * 
 * @param {Struct.NetworkClient} _networkClient The underlying network transport client.
 * @param {String} _username
 */
function Client(_networkClient, _username) constructor {
	CLASS_LOG;
	
	jsonRpc = new JsonRpc(ClientProc, ServerProc);
	events = new EventEmitter("connect", "connectFailed", "disconnect");
	
	networkClient = _networkClient;
	username = _username;
	
	clientId = undefined;
	FEATHERHINT { clientId = 0 }
	
	clientList = undefined;
	FEATHERHINT { clientList = [{ id: 0, username: "orca" }] }
	
	/**
	 * Attempt to create a connection with the network client.
	 */
	static connect = function() {
		networkClient.connect();
	}
	
	/**
	 * Dispose of this client.
	 * This method **MUST** be called to clean up the resources used by this client.
	 */
	static dispose = function() {
		networkClient.dispose();
	}
	
	/**
	 * Get the name of another player by their ID.
	 * 
	 * @pure
	 * @param {Id.Socket} clientId
	 * @returns {String}
	 */
	static getClientName = function(clientId) {
		for (var i = 0; i < array_length(clientList); i ++) {
			if (clientList[i].id == clientId) {
				return clientList[i].username;
			}
		}
	}
	
	/**
	 * Call a remote procedure on the server.
	 * 
	 * @private
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static sendRequest = function(procedure, params, callback) {
		networkClient.sendJson(jsonRpc.createRequest(procedure, params, callback));
	}
	
	/**
	 * Send a notification to the server without expecting a response.
	 * 
	 * @private
	 * @param {Struct.JsonRpcProcedure} procedure
	 * @param {Struct.Message} params
	 */
	static sendNotification = function(procedure, params) {
		networkClient.sendJson(jsonRpc.createNotification(procedure, params));
	}
	
	/**
	 * Respond to a remote procedure call from the server, with the specified response data.
	 * 
	 * @private
	 * @param {Struct.JsonRpcIncomingRequest} request The request for which we are responding to.
	 * @param {Struct.Message} response The response data to send.
	 */
	static sendResponse = function(request, response) {
		networkClient.sendJson(jsonRpc.createResponse(request, response));
	}
	
	#region Network event handlers
	
	networkClient.events.on("connect", function() {
		sendRequest(ServerProc.join, new C2S_ConnectBeginHandshake(username), function(result, error) {
			if (!is_undefined(error)) {
				return events.emit("connectFailed", error);
			}
			
			clientId = result.yourId;
			clientList = result.clientList;
			
			return events.emit("connect", result);
		});
	});
	
	networkClient.events.on("connectFailed", function() {
		log.error("Failed to connect to the server.");
		events.emit("connectFailed");
	});
	
	networkClient.events.on("disconnect", function() {
		log.error("Disconnected from the server.");
		events.emit("disconnect");
	});
	
	networkClient.events.on("data", function(buffer) {
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Got packet: `{text}`");
		
		try {
			json = json_parse(text);
		} catch (err) {
			log.error(new Err("TODO: Failed to parse inbound message from the server!", err));
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
		procedureHandler(request, request.params);
	});
	
	#endregion
	#region RPC request handlers
	
	/**
	 * Respond to server heartbeat pings.
	 * 
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.S2C_Heartbeat} params
	 */
	static onHeartbeat = function(request, params) {
		sendResponse(request, new C2S_HeartbeatReply());
	}
	
	/**
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.S2C_OtherPlayerJoined} params
	 */
	static onOtherPlayerJoined = function(request, params) {
		array_push(clientList, {
			id: params.id,
			username: params.username,
		});
		
		log.info($"{params.username} has joined the server.");
	}
	
	/**
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.S2C_ChatMessageAdded} params
	 */
	static onAddChatMessage = function(request, params) {
		log.info($"{getClientName(params.senderId)} said: {params.message}");
	}
	
	#endregion
	
	/**
	 * List of registered handlers for procedures on the client.
	 * @ignore
	 */
	static procedureHandlers = {};
	
	if (struct_names_count(procedureHandlers) == 0) {
		procedureHandlers[$ ClientProc.heartbeat.name] = onHeartbeat;
		procedureHandlers[$ ClientProc.otherPlayerJoined.name] = onOtherPlayerJoined;
		procedureHandlers[$ ClientProc.addChatMessage.name] = onAddChatMessage;
		
		// Ensure all procedures have been registered.
		Assert.eq(struct_get_names(procedureHandlers), struct_get_names(ClientProc));
	}
}
