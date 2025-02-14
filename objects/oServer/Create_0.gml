/**
 * @desc 
 */

#macro DEFAULT_PORT 27015 

self.log = new LogChannel("server");

FEATHERHINT self.port = 0;

self.clients = [];
FEATHERHINT array_push(self.clients, network_create_socket(network_socket_ws));

self.socket = network_create_server(network_socket_ws, self.port, 8);

if (self.socket < 0) {
	throw new Err($"TODO: Unhandled failure to bind server to port {self.port}!");
}

self.log.debug($"Up on port {self.port}");

/**
 * Handle a client's disconnection.
 * @param {Id.Socket} client
 */
onDisconnect = function(client) {
	self.log.debug($"`{client}` is disconnecting");
	array_delete(self.clients, array_get_index(self.clients, client), 1);
};
