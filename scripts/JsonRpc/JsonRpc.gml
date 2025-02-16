
/**
 * A JSON-RPC v2.0 client AND server, as specified at [https://www.jsonrpc.org/specification](https://www.jsonrpc.org/specification)
 * 
 * @param {Array<Struct.JsonRpcProcedure>} procedures
 */
function JsonRpc(procedures) constructor {
	
	self.procedures = procedures;
	self.activeIds = {};
	
	/**
	 * Handle an incoming message, calling the appropriate procedure.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json
	 */
	static handleIncoming = function(json) {
		
		Assert.cond(is_struct(json));
		Assert.eq(json[$ "jsonrpc"], "2.0");
		
		var isResponse = json[$ "__isResponse"];
		Assert.cond(is_bool(isResponse));
		
		var messageId = json[$ "id"];
		
		if (!isResponse) {
			
			if (!is_undefined(messageId)) {
				Assert.cond(is_real(messageId));
			}
			
			var methodName = json[$ "method"];
			Assert.cond(is_string(methodName));
			
			var params = json[$ "params"];
			
			if (!is_undefined(params)) {
				Assert.cond(is_struct(params));
			}
			
		} else {
			
			Assert.cond(is_real(messageId));
			
			var result = json[$ "result"];
			
			if (is_undefined(result)) {
				
				var error = json[$ "error"];
				Assert.cond(!is_undefined(error));
				
			}
			
		}
		
		
		
	};
	
}

function JsonRpcProcedure(paramsType) constructor {
	
}

function JsonRpcNotification(paramsType) constructor {
	
}
