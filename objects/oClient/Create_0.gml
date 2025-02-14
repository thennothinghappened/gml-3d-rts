/**
 * @desc 
 */

self.log = new LogChannel("client");

FEATHERHINT self.ip = "localhost";
FEATHERHINT self.port = 0;

self.socket = network_create_socket(network_socket_ws);
self.log.debug($"Trying to connect to {self.ip}:{self.port}");

network_connect_async(self.socket, self.ip, self.port);
