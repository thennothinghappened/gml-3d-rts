/**
 * @desc 
 */

self.log = new LogChannel("gui");

self.gui = new HLGui([
	new HLGuiMenuWindow("Main Menu", 50, 50, 200, true, false, [
		new HLGuiColumn([
			new HLGuiButton("Create Server", function() {
				
				var port = DEFAULT_PORT;
				
				instance_create_depth(0, 0, 0, oServer, { port });
				instance_create_depth(0, 0, 0, oClient, { ip: "localhost", port });
				
			}),
			new HLGuiButton("Join Server", function() {
				
				var ip = get_string("IP", "localhost");
				var port = DEFAULT_PORT;
				
				instance_create_depth(0, 0, 0, oClient, { ip, port });
				
			}),
		], 8)
	])
]);

