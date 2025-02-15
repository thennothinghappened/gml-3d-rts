
/**
 * A game client!
 * 
 * @param {Struct.NetworkClient} networkClient The underlying network transport client. Defaults to using TCP.
 */
function Client(networkClient = new NetworkClient(network_socket_tcp)) constructor {
	
	static log = new LogChannel("client");
	
	self.events = new EventEmitter("connect", "connectFailed", "disconnect");
	
	self.networkClient = networkClient;
	self.networkClient.events.on("connect", method(self, self.onConnect));
	self.networkClient.events.on("connectFailed", method(self, self.onConnectFailed));
	self.networkClient.events.on("disconnect", method(self, self.onDisconnect));
	self.networkClient.events.on("data", method(self, self.onData));
	
	/**
	 * Attempt to connect to the server hosted at `ip:port`.
	 * 
	 * @param {String} ip The IP of the server.
	 * @param {Real} port The port the server is running on.
	 */
	static connect = function(ip, port) {
		self.networkClient.connect(ip, port);
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
		log.info("Connected to the server!");
		self.events.emit("connect");
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
			throw new Err("TODO: Failed to parse inbound message from the server!");
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
