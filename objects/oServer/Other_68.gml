/**
 * @desc 
 */

if (async_load[? "id"] != self.socket) {
	exit;
}

var client = async_load[? "socket"];

switch (async_load[? "type"]) {
	
	case network_type_connect:
		self.log.debug($"New connection from `{client}`");
		array_push(self.clients, client);
	break;
	
	case network_type_data:
		
	break;
	
	case network_type_disconnect:
		self.log.debug($"`{client}` is disconnecting");
		array_delete(self.clients, array_get_index(self.clients, client), 1);
	break;
	
}
