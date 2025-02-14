/**
 * @desc Extremely flakey and unstable networking test. This is NOT by any means final, we're mixing transport, serialization and game logic.
 */

if (async_load[? "id"] != self.socket) {
	exit;
}

var client = async_load[? "socket"];

switch (async_load[? "type"]) {
	
	case network_type_connect:
		self.log.debug($"New connection from `{client}`");
		array_push(self.clients, client);
	break;
	
	case network_type_data:
		
		var buffer = async_load[? "buffer"];
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		try {
			json = json_parse(text);
		} catch (_) {
			throw new Err("TODO: Failed to parse inbound message from client!");
		}
		
		self.log.debug($"Got packet: {json}");
	
		if (!is_struct(json)) {
			throw new Err("TODO: client sent a non-struct packet!");
		}
	
		var type = json[$ "type"];
	
		if (!is_string(type)) {
			throw new Err("TODO: client sent a non-string packet type!");
		}
	
		switch (type) {
			case "disconnect":
				self.onDisconnect(client);
			break;
		}
	
	break;
	
	case network_type_disconnect:
		self.onDisconnect(client);
	break;
	
}
