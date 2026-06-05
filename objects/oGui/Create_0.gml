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
	},
	server: undefined,
	client: undefined,
	nextChatMessage: "",
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

self.lobbyLoadingScreen = new HLGuiMenuWindow("Connecting!", display_get_gui_width() / 2 - 150, display_get_gui_height() / 2 - 100, 300, false, false, [
	new HLGuiText(function() {
		var dotCount = ceil((sin(current_time / 240) + 1) * 3);
		return $"Connecting{string_repeat(".", dotCount)}";
	})
]);

chatBoxComponent = function() {
	return new HLGuiRow([
		HLGuiInput("Chat Message",
			function() { return data.nextChatMessage },
			function(nextChatMessage) { data.nextChatMessage = nextChatMessage }
		),
		new HLGuiButton("Send", function() {
			var message = string_trim(data.nextChatMessage);
			
			if (message == "") {
				return;
			}
			
			// TODO: implement a nice server interface like the server has for clients.
			data.client.sendNotification(ServerProc.sendChatMessage, new C2S_ChatMessage(ChatMessageVisibility.Global, message));
			data.nextChatMessage = "";
		})
	]);
}

serverLobbyPlayerList = new HLGuiColumn([]);

serverLobbyScreen = new HLGuiMenuWindow("Lobby", display_get_gui_width() / 2 - 300, 100, 600, false, false, [
	new HLGuiColumn([
		new HLGuiBorderBox(8, 8, [
			new HLGuiRow([
				HLGuiLabel("Hosting!"),
				new HLGuiText(function() { return $"Port: {data.setupServerModal.port}" })
			])
		]),
		new HLGuiBorderBox(8, 8, [serverLobbyPlayerList]),
		chatBoxComponent()
	])
]);

self.setupServerModal = new HLGuiMenuWindow("Host a Server", display_get_gui_width() / 2 - 150, display_get_gui_height() / 2 - 100, 300, false, false, [
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

self.clientLobbyPlayerList = new HLGuiColumn([]);
self.clientLobbyScreen = new HLGuiMenuWindow("Lobby", display_get_gui_width() / 2 - 300, 100, 600, false, false, [
	new HLGuiColumn([
		new HLGuiBorderBox(8, 8, [
			new HLGuiText(function() {
				return $"IP: {self.data.joinServerModal.ip}, Port: {self.data.joinServerModal.port}";
			})
		]),
		new HLGuiBorderBox(8, 8, [clientLobbyPlayerList]),
		chatBoxComponent()
	])
]);

self.joinServerModal = new HLGuiMenuWindow("Connect to a Server", display_get_gui_width() / 2 - 150, display_get_gui_height() / 2 - 100, 300, false, false, [
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
		
		self.data.server = new Server(new NetworkServer(network_socket_ws, port, 8));
		self.data.client = new Client(new NetworkClient(network_socket_ws, "localhost", port), oGame.prefs.username);
		
		self.data.client.events.once("connect", function() {
			self.fsm.change("serverLobbyScreen");
		});
		
		self.data.client.events.once("connectFailed", function() {
			
			self.data.server.dispose();
			self.data.client.dispose();
			
			self.log.error("Failed to host a server!");
			self.fsm.change("mainMenu");
			
		});
		
		self.data.server.listen();
		self.data.client.connect();
		
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
		
		self.data.client = new Client(new NetworkClient(network_socket_ws, ip, port), oGame.prefs.username);
		
		self.data.client.events.once("connect", function() {
			self.fsm.change("clientLobbyScreen");
		});
		
		self.data.client.events.once("connectFailed", function(error) {
			self.log.error($"Failed to connect to the server: {error}");
			self.fsm.change("T.clientDisconnect");
		});
		
		self.data.client.connect();
		
		return "connectingScreen";
		
	}
});

self.fsm.state("T.clientDisconnect", {
	enter: function() {
		
		self.data.client.dispose();
		delete self.data.client;
		
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

#endregion

self.gui = new HLGui([
	self.mainMenuWindow,
	self.clientLobbyScreen,
	self.serverLobbyScreen,
	self.lobbyLoadingScreen,
	self.joinServerModal,
	self.setupServerModal
]);
