/**
 * @desc 
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
		
	break;
	
	case network_type_disconnect:
		self.log.debug("Disconnected!");
		oGui.lobbyWindow.setVisible(false);
		oGui.lobbyLoadingScreen.setVisible(true);
		oGui.lobbyMainScreen.setVisible(false);
	break;
	
}
