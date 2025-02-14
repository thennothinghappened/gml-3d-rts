/**
 * @desc Handle incoming packets.
 */

var socket = async_load[? "id"];
var type = async_load[? "type"];

if (type == network_type_data) {
	if (ds_map_exists(async_load, "server")) {
		socket = async_load[? "server"];
	}
}

var handler = self.socketMap[? socket];

if (!is_undefined(handler)) {
	handler(async_load);
}
