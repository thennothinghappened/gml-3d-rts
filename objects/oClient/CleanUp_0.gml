/**
 * @desc Hopefully send out a disconnection message before we go. Presumably a forced quit is occurring.
 */

var message = { type: "disconnect" };
var text = json_stringify(message);

self.networkClient.sendText(text);
self.networkClient.dispose();
