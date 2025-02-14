/**
 * @desc Hopefully send out a disconnection message before we go. Presumably a forced quit is occurring.
 */

var message = { type: "disconnect" };
var text = json_stringify(message);
var buffer = buffer_create(string_byte_length(text), buffer_fixed, 1);

buffer_write(buffer, buffer_text, text);
network_send_packet(self.socket, buffer, buffer_get_size(buffer));
buffer_delete(buffer);
