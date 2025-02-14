
/**
 * @param {Constant.SocketType} protocol
 */
function NetworkClient(protocol) constructor {
	
	self.protocol = protocol;
	
	/**
	 * The network socket associated with this client.
	 * @ignore
	 */
	self.socket = network_create_socket(protocol);
	
	/**
	 * Whether the client is connnected to a server.
	 */
	self.connected = false;
	
	/**
	 * Events for the client.
	 * 
	 * ### Events
	 * 
	 * #### `connect`: `() -> Undefined`
	 * Sent upon successful connection to a server.
	 * 
	 * #### `connectFailed`: `() -> Undefined`
	 * Sent upon failure to connect to a server.
	 * 
	 * #### `data`: `(buffer: Id.Buffer) -> Undefined`
	 * Sent upon receiving data from the server. The buffer provided is to be considered read-only, and is
	 * managed by GameMaker - do not delete it.
	 * 
	 * #### `disconnect`: `() -> Undefined`
	 * Sent upon disconnection from a server.
	 * 
	 */
	self.events = new EventEmitter("connect", "connectFailed", "data", "disconnect");
	
	NETMANAGER.register(self.socket, function(map) {
		
		switch (async_load[? "type"]) {
	
			case network_type_non_blocking_connect:
				if (async_load[? "succeeded"]) {
					self.connected = true;
					self.events.emit("connect", undefined);
				} else {
					self.events.emit("connectFailed", undefined);
				}
			break;
			
			case network_type_data:
				self.events.emit("data", async_load[? "buffer"]);
			break;
			
			case network_type_disconnect:
				self.connected = false;
				self.events.emit("disconnect", undefined);
			break;
			
		}
		
	});
	
	/**
	 * Attempt to connect to the given IP and Port.
	 * 
	 * @param {String} ip
	 * @param {Real} port
	 */
	static connect = function(ip, port) {
		
		Assert.cond(!self.connected, "Client should not be already connected");
		
		self.connected = false;
		network_connect_async(self.socket, ip, port);
		
	};
	
	/**
	 * Send a binary message to the remote server.
	 * 
	 * @param {Id.Buffer} buffer
	 */
	static sendBuffer = function(buffer) {
		Assert.cond(self.connected, "Client should be connected");
		network_send_packet(self.socket, buffer, buffer_get_size(buffer));
	};
	
	/**
	 * Send a textual message to the remote server.
	 * 
	 * @param {String} text
	 */
	static sendText = function(text) {
		
		Assert.cond(self.connected, "Client should be connected");
		
		var buffer = buffer_create(string_byte_length(text), buffer_fixed, 1);
		
		buffer_write(buffer, buffer_text, text);
		self.sendBuffer(buffer);
		buffer_delete(buffer);
		
	};
	
	/**
	 * Dispose of this network client. This MUST be called to correctly clean up the resources used.
	 */
	static dispose = function() {
		network_destroy(self.socket);
		NETMANAGER.deregister(self.socket);
	};
	
}
