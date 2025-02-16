
#macro DEFAULT_PORT 27015

/**
 * @param {Constant.SocketType} protocol
 * @param {Real} port
 * @param {Real} maxClients
 */
function NetworkServer(protocol, port, maxClients) constructor {
	
	CLASS_LOG;
	
	/**
	 * @type {Constant.SocketType}
	 */
	self.protocol = protocol;
	
	/**
	 * The port that this server listens on.
	 */
	self.port = port;
	
	/**
	 * The maximum number of clients that may connect to this server.
	 */
	self.maxClients = maxClients;
	
	/**
	 * The network socket associated with this server.
	 * @type {Id.Socket|Undefined}
	 */
	self.socket = undefined;
	
	/**
	 * Events for the server.
	 * 
	 * ### Events
	 * 
	 * #### `connect`: `(client: Id.Socket) -> Undefined`
	 * Sent upon a client successfully connecting to the server.
	 * 
	 * #### `data`: `(client: Id.Socket, buffer: Id.Buffer) -> Undefined`
	 * Sent upon receiving data from the given client. The buffer provided is to be considered read-only, and is
	 * managed by GameMaker - do not delete it.
	 * 
	 * #### `disconnect`: `(client: Id.Socket) -> Undefined`
	 * Sent upon a client disconnecting from the server.
	 * 
	 */
	self.events = new EventEmitter("connect", "data", "disconnect");
	
	/**
	 * Begins listening on the network for clients.
	 * Returns whether the operation was successful.
	 * 
	 * @returns {Bool}
	 */
	static listen = function() {
		
		Assert.eq(self.socket, undefined);
		
		self.socket = network_create_server(self.protocol, self.port, self.maxClients);
		
		if (self.socket < 0) {
			self.socket = undefined;
			return false;
		}
		
		NETMANAGER.register(self.socket, method(self, self.handleNetMessage));
		log.info($"Up on port {self.port}");
		
		return true;
		
	};
	
	/**
	 * Set a different port to bind to, instead of the one that was initially specified.
	 * 
	 * This method may only be called if the server is not currently listening.
	 * 
	 * @param {Real} port
	 */
	static setPort = function(port) {
		
		Assert.eq(self.socket, undefined);
		self.port = port;
		
	};
	
	/**
	 * Send a buffer to the given client.
	 * 
	 * @param {Id.Socket} client
	 * @param {Id.Buffer} buffer
	 */
	static sendBuffer = function(client, buffer) {
		Assert.neq(self.socket, undefined);
		network_send_packet(client, buffer, buffer_get_size(buffer));
	};
	
	/**
	 * Send textual data to the given client.
	 * 
	 * @param {Id.Socket} client
	 * @param {String} text
	 */
	static sendText = function(client, text) {
		
		var buffer = buffer_create(string_byte_length(text), buffer_fixed, 1);
		buffer_write(buffer, buffer_text, text);
		
		self.sendBuffer(client, buffer);
		buffer_delete(buffer);
		
	};
	
	/**
	 * Dispose of this server. This MUST be called to correctly clean up the resources used.
	 */
	static dispose = function() {
		
		if (!is_undefined(self.socket)) {
			network_destroy(self.socket);
			NETMANAGER.deregister(self.socket);
		}
		
	};
	
	/**
	 * Handle an incoming network message.
	 * 
	 * @ignore
	 * @param {Id.DsMap} map
	 */
	static handleNetMessage = function(map) {
			
		var client;
		
		switch (async_load[? "type"]) {
	
			case network_type_connect:
			
				client = async_load[? "socket"];
				Assert.neq(client, self.socket);
			
				self.events.emit("connect", client);
			
			break;
			
			case network_type_data:
			
				client = async_load[? "id"];
				Assert.neq(client, self.socket);
			
			
				self.events.emit("data", client, async_load[? "buffer"]);
			break;
			
			case network_type_disconnect:
			
				client = async_load[? "socket"];
				Assert.neq(client, self.socket);
			
				self.events.emit("disconnect", client);
			
			break;
			
		}
		
	};
	
}
