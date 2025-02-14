/**
 * @desc 
 */

self.log = new LogChannel("gui");
self.log.info("Hello!");

self.mainMenuWindow = new HLGuiMenuWindow("Main Menu", 50, 50, 200, true, false, [
	new HLGuiColumn([
		new HLGuiButton("Create Server", function() {
			
			var port = DEFAULT_PORT;
			
			instance_create_depth(0, 0, 0, oServer, { port });
			instance_create_depth(0, 0, 0, oClient, { ip: "localhost", port });
			
			self.lobbyWindow.setVisible(true);
			
		}),
		new HLGuiButton("Join Server", function() {
			self.ipModal.setVisible(true);
		}),
	], 8)
]);

self.serverIp = "localhost";
self.serverPort = $"{DEFAULT_PORT}";

self.ipModal = new HLGuiMenuWindow("Connect to a Server", window_get_width() / 2 - 150, window_get_height() / 2 - 100, 300, false, true, [
	new HLGuiColumn([
		HLGuiInput("IP",
			function() { return self.serverIp },
			function(value) { self.serverIp = value }
		),
		HLGuiInput("Port",
			function() { return self.serverPort },
			function(value) { self.serverPort = string_digits(value) }
		),
		new HLGuiRow([
			new HLGuiButton("Cancel", function() {
				self.ipModal.setVisible(false);
			}),
			new HLGuiButton("Join", function() {
				
				self.ipModal.setVisible(false);
				self.lobbyWindow.setVisible(true);
				
				var ip = self.serverIp;
				var port = realOrUndefined(self.serverPort) ?? DEFAULT_PORT;
				
				instance_create_depth(0, 0, 0, oClient, { ip, port });
				self.lobbyWindow.setVisible(true);
				
			})
		], 16)
	], 16)
]);

self.lobbyLoadingScreen = new HLGuiBox([
	new HLGuiText(function() {
		var dotCount = ceil((sin(current_time / 240) + 1) * 3);
		return $"Connecting{string_repeat(".", dotCount)}";
	})
]);

self.lobbyLoadingScreen.setVisible(true);

self.lobbyPlayerList = new HLGuiColumn([]);

self.lobbyMainScreen = new HLGuiColumn([
	new HLGuiBorderBox(8, 8, [
		new HLGuiText(function() {
		
			var text = "";
			
			if (instance_exists(oServer)) {
				text += "[Hosting] ";
			}
			
			text += $"IP: {oClient.ip}, Port: {oClient.port}";
			
			return text;
		})
	]),
	new HLGuiBorderBox(8, 8, [
		self.lobbyPlayerList
	]),
]);

self.lobbyMainScreen.setVisible(false);

self.lobbyWindow = new HLGuiMenuWindow("Lobby", window_get_width() / 2 - 200, 100, 400, false, false, [
	self.lobbyLoadingScreen,
	self.lobbyMainScreen
]);

self.gui = new HLGui([
	self.mainMenuWindow,
	self.lobbyWindow,
	self.ipModal
]);
