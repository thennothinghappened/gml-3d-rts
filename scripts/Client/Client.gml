
/**
 * A game client!
 * 
 * @param {Struct.NetworkClient} networkClient The underlying network transport client.
 */
function Client(networkClient) constructor {
	
	CLASS_LOG;
	
	static procedureHandlers = {};
	
	self.jsonRpc = new JsonRpc(clientProcedures(), serverProcedures());
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
	 * Called upon successful connection to the server.
	 * @ignore
	 */
	static onNetConnect = function() {
		
		var message = self.jsonRpc.createRequest("join", new ClientJoinInfo(oGame.prefs.username), function(result, error) {
			
			if (!is_undefined(error)) {
				return self.events.emit("connectFailed", error);
			}
			
			return self.events.emit("connect", result);
			
		});
		
		self.networkClient.sendJson(message);
		
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
	
	if (struct_names_count(procedureHandlers) == 0) {
		//procedureHandlers[$ serverProcedures.join.name] = self.onJoin;
	}
	
}

/**
 * Obtain the list of procedures on a game client.
 * @pure
 */
function clientProcedures() {
	
	static list = [
		
	];
	
	return list;
	
}
