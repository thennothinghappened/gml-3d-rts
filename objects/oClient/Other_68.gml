/**
 * @desc Extremely flakey and unstable networking test. This is NOT by any means final, we're mixing transport, serialization and game logic.
 */

if (async_load[? "id"] != self.socket) {
	exit;
}

switch (async_load[? "type"]) {
	
	case network_type_non_blocking_connect:
		self.log.debug("Connected!");
		oGui.lobbyLoadingScreen.setVisible(false);
		oGui.lobbyMainScreen.setVisible(true);
	break;
	
	case network_type_data:
		
		var buffer = async_load[? "buffer"];
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		try {
			json = json_parse(text);
		} catch (_) {
			throw new Err("TODO: Failed to parse inbound message from server!");
		}
		
		self.log.debug($"Got packet: {json}");
	
	break;
	
	case network_type_disconnect:
		self.log.debug("Disconnected!");
		oGui.lobbyWindow.setVisible(false);
		oGui.lobbyLoadingScreen.setVisible(true);
		oGui.lobbyMainScreen.setVisible(false);
	break;
	
}
