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
