/**
 * @desc Manager for network packets for clients and servers alike.
 */

#macro NETMANAGER oNetworkManager 

// Singleton should not have multiple instances.
Assert.eq(instance_number(object_index), 1);

/**
 * List of sockets and associated handling functions for them.
 * @ignore
 */
self.socketMap = ds_map_create();
FEATHERHINT self.socketMap[? network_create_socket(network_socket_tcp)] = /** @param {Id.DsMap} event */ function(event) {};

/**
 * Register the given socket and handler callback with the manager.
 * 
 * @param {Id.Socket} socket The socket to register.
 * @param {Function} handler `(Id.DsMap) -> Undefined` \| A handler callback to be invoked with the contents of `async_load`
 */
register = function(socket, handler) {
	self.socketMap[? socket] = handler;
};

/**
 * Deregister the given socket.
 * 
 * @param {Id.Socket} socket The socket to deregister.
 */
deregister = function(socket) {
	ds_map_delete(self.socketMap, socket);
};
