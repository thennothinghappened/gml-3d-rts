
/**
 * A game client!
 * 
 * @param {Struct.NetworkClient} networkClient The underlying network transport client.
 */
function Client(networkClient) constructor {
	
	CLASS_LOG;
	
	self.jsonRpc = new JsonRpc(ClientProc.procedureList, ServerProc.procedureList);
	self.events = new EventEmitter("connect", "connectFailed", "disconnect");
	
	self.networkClient = networkClient;
	self.networkClient.events.on("connect", method(self, self.onNetConnect));
	self.networkClient.events.on("connectFailed", method(self, self.onNetConnectFailed));
	self.networkClient.events.on("disconnect", method(self, self.onNetDisconnect));
	self.networkClient.events.on("data", method(self, self.onNetData));
	
	/**
	 * Attempt to create a connection with the network client.
	 */
	static connect = function() {
		self.networkClient.connect();
	};
	
	/**
	 * Dispose of this client.
	 * This method **MUST** be called to clean up the resources used by this client.
	 */
	static dispose = function() {
		self.networkClient.dispose();
	};
	
	/**
	 * Call a remote procedure on the server.
	 * 
	 * @private
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static call = function(procedure, params, callback) {
		self.networkClient.sendJson(self.jsonRpc.createRequest(procedure, params, callback));
	};
	
	/**
	 * Respond to a remote procedure call from the server, with the specified response data.
	 * 
	 * @private
	 * @param {Struct.JsonRpcIncomingRequest} request The request for which we are responding to.
	 * @param {Struct.Message} response The response data to send.
	 */
	static respond = function(request, response) {
		self.networkClient.sendJson(self.jsonRpc.createResponse(request, response));
	};
	
	/**
	 * Respond to server heartbeat pings.
	 * 
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.ServerJoinRequest} params
	 */
	static onHeartbeat = function(request, params) {
		self.respond(request, new ClientHeartbeatResponse());
	};
	
	/**
	 * Called upon successful connection to the server.
	 * @ignore
	 */
	static onNetConnect = function() {
		
		self.call(ServerProc.join, new ServerJoinRequest(
			oGame.prefs.uuid,
			oGame.prefs.username
		), function(result, error) {
			
			if (!is_undefined(error)) {
				return self.events.emit("connectFailed", error);
			}
			
			return self.events.emit("connect", result);
			
		});
		
	};
	
	/**
	 * Called upon failure to connect to the server.
	 * @ignore
	 */
	static onNetConnectFailed = function() {
		log.error("Failed to connect to the server.");
		self.events.emit("connectFailed");
	};
	
	/**
	 * Called upon disconnection from the server.
	 * @ignore
	 */
	static onNetDisconnect = function() {
		log.error("Disconnected from the server.");
		self.events.emit("disconnect");
	};
	
	/**
	 * Called upon receiving a data packet from the server.
	 * @ignore
	 */
	static onNetData = function(buffer) {
		
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
		
	};
	
	/**
	 * List of registered handlers for procedures on the client.
	 * @ignore
	 */
	static procedureHandlers = {};
	
	if (struct_names_count(procedureHandlers) == 0) {
		
		procedureHandlers[$ ClientProc.heartbeat.name] = self.onHeartbeat;
		
		// Ensure all procedures have been registered.
		Assert.eq(struct_names_count(procedureHandlers), array_length(ClientProc.procedureList));
		
	}
	
}
