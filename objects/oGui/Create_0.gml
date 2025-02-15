/**
 * @desc 
 */

self.log = new LogChannel("gui");
self.log.info("Hello!");

self.data = {
	setupServerModal: {
		port: $"{DEFAULT_PORT}"
	},
	joinServerModal: {
		ip: "localhost",
		port: $"{DEFAULT_PORT}"
	}
};

self.mainMenuWindow = new HLGuiMenuWindow("Main Menu", 50, 50, 200, false, false, [
	new HLGuiColumn([
		new HLGuiButton("Create Server", function() {
			self.fsm.change("setupServerModal");
		}),
		new HLGuiButton("Join Server", function() {
			self.fsm.change("joinServerModal");
		}),
	], 8)
]);

self.lobbyLoadingScreen = new HLGuiMenuWindow("Connecting!", window_get_width() / 2 - 150, window_get_height() / 2 - 100, 300, false, false, [
	new HLGuiText(function() {
		var dotCount = ceil((sin(current_time / 240) + 1) * 3);
		return $"Connecting{string_repeat(".", dotCount)}";
	})
]);

#region Main Menu

self.fsm = new FSM("mainMenu");

self.fsm.state("mainMenu", {
	
	enter: function() {
		self.mainMenuWindow.setVisible(true);
	},
	
	leave: function() {
		self.mainMenuWindow.setVisible(false);
	}
	
});

self.fsm.state("connectingScreen", {
	
	enter: function() {
		self.lobbyLoadingScreen.setVisible(true);
	},
	
	leave: function() {
		self.lobbyLoadingScreen.setVisible(false);
	}
	
});

#endregion
#region Server Hosting

self.fsm.state("setupServerModal", {
	
	enter: function() {
		self.setupServerModal.setVisible(true);
	},
	
	leave: function() {
		self.setupServerModal.setVisible(false);
	}
	
});

self.fsm.state("T.startServer", {
	enter: function() {
		
		var port = realOrUndefined(self.data.setupServerModal.port) ?? DEFAULT_PORT;
			
		instance_create_depth(0, 0, 0, oServer, { port });
		instance_create_depth(0, 0, 0, oClient, { ip: "localhost", port });
		
		oClient.events.once("connect", function() {
			self.fsm.change("serverLobbyScreen");
		});
		
		oClient.events.once("connectFailed", function() {
			
			with (oServer) {
				instance_destroy(self);
			}
			
			with (oClient) {
				instance_destroy(self);
			}
			
			self.log.error("Failed to host a server!");
			self.fsm.change("mainMenu");
			
		});
		
		return "connectingScreen";
		
	}
});

self.fsm.state("serverLobbyScreen", {
	
	enter: function() {
		self.serverLobbyScreen.setVisible(true);
	},
	
	leave: function() {
		self.serverLobbyScreen.setVisible(false);
	}
	
});

self.serverLobbyPlayerList = new HLGuiColumn([]);
self.serverLobbyScreen = new HLGuiMenuWindow("Lobby", window_get_width() / 2 - 300, 100, 600, false, false, [
	new HLGuiColumn([
		new HLGuiBorderBox(8, 8, [
			new HLGuiRow([
				HLGuiLabel("Hosting!"),
				new HLGuiText(function() {
					return $"IP: {oClient.ip}, Port: {oClient.port}";
				})
			])
		]),
		new HLGuiBorderBox(8, 8, [
			self.serverLobbyPlayerList
		]),
	])
]);

self.setupServerModal = new HLGuiMenuWindow("Host a Server", window_get_width() / 2 - 150, window_get_height() / 2 - 100, 300, false, false, [
	new HLGuiColumn([
		HLGuiInput("Port",
			function() { return self.data.setupServerModal.port },
			function(value) { self.data.setupServerModal.port = string_digits(value) }
		),
		new HLGuiRow([
			new HLGuiButton("Cancel", function() {
				self.fsm.change("mainMenu");
			}),
			new HLGuiButton("Host", function() {
				self.fsm.change("T.startServer");
			})
		], 16)
	], 16)
]);

#endregion
#region Client

self.fsm.state("joinServerModal", {
	
	enter: function() {
		self.joinServerModal.setVisible(true);
	},
	
	leave: function() {
		self.joinServerModal.setVisible(false);
	}
	
});

self.fsm.state("T.clientConnect", {
	enter: function() {
		
		var ip = self.data.joinServerModal.ip;
		var port = realOrUndefined(self.data.joinServerModal.port) ?? DEFAULT_PORT;
		
		instance_create_depth(0, 0, 0, oClient, { ip, port });
		
		oClient.events.once("connect", function() {
			self.fsm.change("clientLobbyScreen");
		});
		
		oClient.events.once("connectFailed", function() {
			self.log.error("Failed to connect to the server!");
			self.fsm.change("T.clientDisconnect");
		});
		
		return "connectingScreen";
		
	}
});

self.fsm.state("T.clientDisconnect", {
	enter: function() {
		instance_destroy(oClient);
		return "mainMenu";
	}
});

self.fsm.state("clientLobbyScreen", {
	
	enter: function() {
		self.clientLobbyScreen.setVisible(true);
	},
	
	leave: function() {
		self.clientLobbyScreen.setVisible(false);
	}
	
});

self.clientLobbyPlayerList = new HLGuiColumn([]);
self.clientLobbyScreen = new HLGuiMenuWindow("Lobby", window_get_width() / 2 - 300, 100, 600, false, false, [
	new HLGuiColumn([
		new HLGuiBorderBox(8, 8, [
			new HLGuiText(function() {
				return $"IP: {oClient.ip}, Port: {oClient.port}";
			})
		]),
		new HLGuiBorderBox(8, 8, [
			self.clientLobbyPlayerList
		]),
	])
]);

self.joinServerModal = new HLGuiMenuWindow("Connect to a Server", window_get_width() / 2 - 150, window_get_height() / 2 - 100, 300, false, false, [
	new HLGuiColumn([
		HLGuiInput("IP",
			function() { return self.data.joinServerModal.ip },
			function(value) { self.data.joinServerModal.ip = value }
		),
		HLGuiInput("Port",
			function() { return self.data.joinServerModal.port },
			function(value) { self.data.joinServerModal.port = string_digits(value) }
		),
		new HLGuiRow([
			new HLGuiButton("Cancel", function() {
				self.fsm.change("mainMenu");
			}),
			new HLGuiButton("Join", function() {
				self.fsm.change("T.clientConnect");
			})
		], 16)
	], 16)
]);

#endregion

self.gui = new HLGui([
	self.mainMenuWindow,
	self.clientLobbyScreen,
	self.serverLobbyScreen,
	self.lobbyLoadingScreen,
	self.joinServerModal,
	self.setupServerModal
]);
