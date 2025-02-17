
/**
 * A game client!
 * 
 * @param {Struct.NetworkClient} networkClient The underlying network transport client.
 */
function Client(networkClient) constructor {
	
	CLASS_LOG;
	
	/**
	 * List of types of messages that can be recieved from the server.
	 * @type {Array<Class<Struct.Message>>}
	 */
	static incomingMessageTypes = [
		ServerJoinInfo
	];
	
	/**
	 * Mapping of message type names to their corresponding class.
	 * @type {Record<String, Class<Struct.Message>>}
	 */
	static incomingMessageTypesMap = {};
	
	// Initialise the message types map.
	if (struct_names_count(incomingMessageTypesMap) == 0) {
		array_foreach(incomingMessageTypes, function(messageType) {
			incomingMessageTypesMap[$ script_get_name(messageType)] = messageType;
		});
	}
	
	self.events = new EventEmitter("connect", "connectFailed", "disconnect");
	
	self.networkClient = networkClient;
	self.networkClient.events.on("connect", method(self, self.onConnect));
	self.networkClient.events.on("connectFailed", method(self, self.onConnectFailed));
	self.networkClient.events.on("disconnect", method(self, self.onDisconnect));
	self.networkClient.events.on("data", method(self, self.onData));
	
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
	static onConnect = function() {
		
		var message = new ClientJoinInfo(oGame.prefs.username);
		self.networkClient.sendText(json_stringify(message.toJson()));
		
	};
	
	/**
	 * Called upon failure to connect to the server.
	 * @ignore
	 */
	static onConnectFailed = function() {
		log.error("Failed to connect to the server.");
		self.events.emit("connectFailed");
	};
	
	/**
	 * Called upon disconnection from the server.
	 * @ignore
	 */
	static onDisconnect = function() {
		log.error("Disconnected from the server.");
		self.events.emit("disconnect");
	};
	
	/**
	 * Called upon receiving a data packet from the server.
	 * @ignore
	 */
	static onData = function(buffer) {
		
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Got packet: `{text}`");
		
		try {
			json = json_parse(text);
		} catch (_) {
			log.error(new Err("TODO: Failed to parse inbound message from the server!"));
			return;
		}
		
		if (!is_struct(json)) {
			throw new Err("TODO: server sent a non-struct packet!");
		}
	
		var type = json[$ "type"];
	
		if (!is_string(type)) {
			throw new Err("TODO: server sent a non-string packet type!");
		}
	
		switch (type) {
			default:
				log.warn($"Unhandled packet type `{type}`!");
			break;
		}
		
	};
	
}
