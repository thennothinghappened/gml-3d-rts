/**
 * @desc 
 */

self.log = new LogChannel("client");

FEATHERHINT self.ip = "localhost";
FEATHERHINT self.port = 0;

self.networkClient = new NetworkClient(network_socket_tcp);

onConnect = function() {
	self.log.info("Connected to the server!");
	oGui.lobbyLoadingScreen.setVisible(false);
	oGui.lobbyMainScreen.setVisible(true);
};

onConnectFailed = function() {
	self.log.error("Failed to connect to the server.");
	oGui.lobbyWindow.setVisible(false);
};

onDisconnect = function() {
	self.log.error("Disconnected from the server.");
	oGui.lobbyWindow.setVisible(false);
	instance_destroy(self);
};

onData = function(buffer) {
	
	var text = buffer_read(buffer, buffer_text);
	var json;
	
	self.log.debug($"Got packet: `{text}`");
	
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
			self.log.warn($"Unhandled packet type `{type}`!");
		break;
	}
	
};

self.networkClient.events.on("connect", self.onConnect);
self.networkClient.events.on("connectFailed", self.onConnectFailed);
self.networkClient.events.on("disconnect", self.onDisconnect);
self.networkClient.events.on("data", self.onData);

self.log.debug($"Trying to connect to {self.ip}:{self.port}");
self.networkClient.connect(self.ip, self.port);
