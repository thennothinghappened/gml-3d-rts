/**
 * @desc 
 */

self.log = new LogChannel("gui");

self.mainMenuWindow = new HLGuiMenuWindow("Main Menu", 50, 50, 200, true, false, [
	new HLGuiColumn([
		new HLGuiButton("Create Server", function() {
			
			var port = DEFAULT_PORT;
			
			instance_create_depth(0, 0, 0, oServer, { port });
			instance_create_depth(0, 0, 0, oClient, { ip: "localhost", port });
			
			self.lobbyWindow.setVisible(true);
			
		}),
		new HLGuiButton("Join Server", function() {
			
			var ip = get_string("IP", "localhost");
			var port = DEFAULT_PORT;
			
			instance_create_depth(0, 0, 0, oClient, { ip, port });
			
			self.lobbyWindow.setVisible(true);
			
		}),
	], 8)
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
			return $"Port: {oClient.port}";
		})
	]),
	new HLGuiBorderBox(8, 8, [
		self.lobbyPlayerList
	]),
]);

self.lobbyMainScreen.setVisible(false);

self.lobbyWindow = new HLGuiMenuWindow("Lobby", window_get_width() / 2 - 200, 100, 200, false, false, [
	self.lobbyLoadingScreen,
	self.lobbyMainScreen
]);

self.gui = new HLGui([
	self.mainMenuWindow,
	self.lobbyWindow
]);
