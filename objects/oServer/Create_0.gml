/**
 * @desc 
 */

#macro DEFAULT_PORT 27015 

self.log = new LogChannel("server");

FEATHERHINT self.port = 0;

self.clients = [];
FEATHERHINT array_push(self.clients, network_create_socket(network_socket_ws));

self.networkServer = new NetworkServer(network_socket_tcp);

/**
 * Handle a client's connection.
 * @param {Id.Socket} client
 */
onConnect = function(client) {
	
	self.log.info($"New connection from `{client}`");
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
 * @param {Id.Socket} client
 */
onDisconnect = function(client) {
	self.log.debug($"`{client}` is disconnecting");
	array_delete(self.clients, array_get_index(self.clients, client), 1);
};

/**
 * Handle incoming data from a client.
 * 
 * @param {Id.Socket} client
 * @param {Id.Buffer} buffer
 */
onData = function(client, buffer) {
	
	var text = buffer_read(buffer, buffer_text);
	var json;
	
	try {
		json = json_parse(text);
	} catch (_) {
		throw new Err("TODO: Failed to parse inbound message from client!");
	}
	
	self.log.debug($"Packet from client `{client}`: {json}");

	if (!is_struct(json)) {
		throw new Err("TODO: client sent a non-struct packet!");
	}

	var type = json[$ "type"];

	if (!is_string(type)) {
		throw new Err("TODO: client sent a non-string packet type!");
	}

	switch (type) {
		default:
			self.log.warn($"Unknown message `{type}` from client `{client}`");
		break;
	}
	
};

self.networkServer.events.on("connect", self.onConnect);
self.networkServer.events.on("disconnect", self.onDisconnect);
self.networkServer.events.on("data", self.onData);

if (!self.networkServer.bind(self.port, 8)) {
	throw new Err($"TODO: Unhandled failure to bind server to port {self.port}!");
}

self.log.info($"Up on port {self.port}");
