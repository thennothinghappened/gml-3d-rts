
/**
 * A server for the game.
 * 
 * @param {Struct.NetworkServer} networkServer The underlying server controller on the network.
 */
function Server(networkServer) constructor {
	
	CLASS_LOG;
	
	/**
	 * List of types of messages that can be recieved from clients.
	 * @type {Array<Class<Struct.Message>>}
	 */
	static incomingMessageTypes = [
		ClientJoinInfo
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
	
	self.clients = [];
	
	self.networkServer = networkServer;
	self.networkServer.events.on("connect", method(self, self.onConnect));
	self.networkServer.events.on("disconnect", method(self, self.onDisconnect));
	self.networkServer.events.on("data", method(self, self.onData));
	
	/**
	 * Begins listening on the network for clients.
	 * Returns whether the operation was successful.
	 * 
	 * @returns {Bool}
	 */
	static listen = function() {
		return self.networkServer.listen();
	}
	
	/**
	 * Dispose of this server.
	 * This method **MUST** be called to clean up the resources used by this server.
	 */
	static dispose = function() {
		self.networkServer.dispose();
	};
	
	/**
	 * Handle a client's connection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onConnect = function(client) {
		
		log.info($"New connection from `{client}`");
		array_push(self.clients, client);
	
		var text = json_stringify({
			type: "connectInfo",
			yourId: client,
			clientIdList: self.clients
		});
		
		self.networkServer.sendText(client, text);
		
	};
	
	/**
	 * Handle a client's disconnection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onDisconnect = function(client) {
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
	static onData = function(client, buffer) {
		
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		try {
			json = json_parse(text);
		} catch (_) {
			throw new Err("TODO: Failed to parse inbound message from client!");
		}
		
		log.debug($"Packet from client `{client}`: {json}");
	
		if (!is_struct(json)) {
			throw new Err("TODO: client sent a non-struct packet!");
		}
	
		var type = json[$ "type"];
	
		if (!is_string(type)) {
			throw new Err("TODO: client sent a non-string packet type!");
		}
	
		switch (type) {
			default:
				log.warn($"Unknown message `{type}` from client `{client}`");
			break;
		}
		
	};
	
}
