
/**
 * A JSON-RPC v2.0 client AND server, as specified at [https://www.jsonrpc.org/specification](https://www.jsonrpc.org/specification)
 * 
 * @param {Array<Struct.JsonRpcProcedure>} localProcedures Procedures we provide that may be called.
 * @param {Array<Struct.JsonRpcProcedure>} remoteProcedures Procedures that we can call on the remote.
 */
function JsonRpc(localProcedures, remoteProcedures) constructor {
	
	self.localProcedureMap = {};
	self.remoteProcedureMap = {};
	
	array_foreach(localProcedures, function(procedure) {
		self.localProcedureMap[$ procedure.name] = procedure;
	});
	
	array_foreach(remoteProcedures, function(procedure) {
		self.remoteProcedureMap[$ procedure.name] = procedure;
	});
	
	/**
	 * List of identifiers currently in use for outbound requests.
	 * When creating a new request, the lowest unused ID will be chosen.
	 * 
	 * The functions associated with these IDs are the functions 
	 * 
	 * @type {Array<Struct.JsonRpcRequest>}
	 */
	self.outboundIds = [];
	
	/**
	 * Handle an incoming message, calling the appropriate procedure.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json
	 * @returns {Struct.JsonRpcIncomingRequest|Undefined}
	 */
	static handleIncoming = function(json) {
		
		Assert.cond(is_struct(json));
		Assert.eq(json[$ "jsonrpc"], "2.0");
		
		var messageId = json[$ "id"];
		
		if (!is_undefined(json[$ "method"])) {
			return self.handleRequest(messageId, json);
		} else {
			return self.handleResponse(messageId, json);
		}
		
	};
	
	/**
	 * Create a JSON-RPC request to the remote to perform the given procedure.
	 * 
	 * If the procedure does not specify a response type, no ID is given, and thus the message is a notification.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the parameters passed are not the correct request message type for the procedure.
	 * 
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call.
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function|Undefined} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static createRequest = function(procedure, params, callback) {
		
		Assert.cond(is_instanceof(params, procedure.requestClass));
		
		var messageId = undefined;
		
		if (!is_undefined(procedure.responseClass)) {
			
			messageId = 0;
			
			while (messageId < array_length(self.outboundIds)) {
				if (is_undefined(self.outboundIds[messageId ++])) {
					break;
				}
			}
			
			Assert.cond(messageId == array_length(self.outboundIds) || is_undefined(self.outboundIds[messageId]));
			self.outboundIds[messageId] = new JsonRpcRequest(procedure, callback);
			
		}
		
		return {
			jsonrpc: "2.0",
			method: procedure.name,
			params: params.toJson(),
			id: messageId
		};
		
	};
	
	/**
	 * Create a JSON-RPC response to a procedure call from the remote.
	 * 
	 * ### Exceptions
	 * 
	 * - Throws if the response passed is not the correct response message type for the procedure.
	 * - Throws if attempting to respond to a notification (no ID).
	 * 
	 * @param {Struct.JsonRpcIncomingRequest} request The incoming request data object.
	 * @param {Struct.Message} response The message to respond with.
	 */
	static createResponse = function(request, response) {
		
		Assert.cond(!is_undefined(request.messageId));
		Assert.cond(is_instanceof(response, request.procedure.responseClass));
		
		return {
			jsonrpc: "2.0",
			result: response.toJson(),
			id: request.messageId
		};
		
	};
	
	/**
	 * Handle an incoming request after determining an RPC packet to be a request to this server.
	 * Returns a struct with the procedure that was called, and the parameters it was called with.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @ignore
	 * @param {Real|Undefined} messageId
	 * @param {Struct.JsonRpcIncomingRequest} json
	 */
	static handleRequest = function(messageId, json) {
		
		if (!is_undefined(messageId)) {
			Assert.cond(is_real(messageId));
		}
		
		var procedureName = json[$ "method"];
		Assert.cond(is_string(procedureName));
		
		var localProcedure = self.localProcedureMap[$ procedureName];
		Assert.cond(!is_undefined(localProcedure));
		
		var paramsJson = json[$ "params"];
		var params = undefined;
		
		if (!is_undefined(localProcedure.requestClass)) {
			params = static_get(localProcedure.requestClass).fromJson(paramsJson);
		}
		
		return new JsonRpcIncomingRequest(messageId, localProcedure, params);
		
	};
	
	/**
	 * Handle a response from the remote.
	 * 
	 * ### Exceptions
	 * 
	 * - Throws if the message is malformed.
	 * - Throws if the message is a response to a non-existent request ID.
	 * - Throws if the message's `result` field, if specified, does not conform to the expected type specified.
	 * 
	 * @ignore
	 * @param {Real} messageId
	 * @param {Struct} json
	 * @returns {Undefined}
	 */
	static handleResponse = function(messageId, json) {
		
		Assert.cond(is_real(messageId));
		Assert.cond(messageId < array_length(self.outboundIds));
		
		var request = self.outboundIds[messageId];
		Assert.cond(!is_undefined(request));
		
		self.outboundIds[messageId] = undefined;
		
		var resultJson = json[$ "result"];
		
		if (is_undefined(resultJson)) {
			
			var errorJson = json[$ "error"];
			Assert.cond(!is_undefined(errorJson));
			
			var error = JsonRpcError.fromJson(errorJson);
			return request.callback(undefined, error);
			
		}
		
		Assert.cond(!is_undefined(request.procedure.responseClass));
		
		var result = static_get(request.procedure.responseClass).fromJson(resultJson);
		return request.callback(result, undefined);
		
	};
	
}

/**
 * A procedure that may be called remotely via JSON-RPC.
 * 
 * @param {String} name Unique name for this procedure.
 * @param {Function.Message|Undefined} requestClass The class of the message type used for requests to this procedure. If `undefined`, no parameters are given.
 * @param {Function.Message|Undefined} responseClass The class of the message type used for responses from this procedure. If `undefined`, this is a notification.
 */
function JsonRpcProcedure(name, requestClass, responseClass) constructor {
	self.name = name;
	self.requestClass = requestClass;
	self.responseClass = responseClass;
}

/**
 * @param {Struct.JsonRpcProcedure} procedure The procedure for which this request is calling.
 * @param {Function} callback A callback function to be executed upon receiving a response for this request.
 */
function JsonRpcRequest(procedure, callback) constructor {
	self.procedure = procedure;
	self.callback = callback;
}

/**
 * An incoming request to a procedure
 * 
 */
function JsonRpcIncomingRequest(messageId, procedure, params) constructor {
	self.messageId = messageId;
	self.procedure = procedure;
	self.params = params;
}

/**
 * @param {Enum.JsonRpcErrorCode} code
 * @param {String} message
 * @param {Any} [data]
 */
function JsonRpcError(code, message, data) : Message() constructor {
	
	self.code = code;
	self.message = message;
	self.data = data;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return { code, message, data };
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.JsonRpcError}
	 */
	static fromJson = function(json) {
		
		Assert.cond(is_struct(json));
		
		var code = json[$ "code"];
		Assert.cond(is_real(code));
		
		var message = json[$ "message"];
		Assert.cond(is_string(message));
		
		var data = json[$ "data"];
		
		return new JsonRpcError(code, message, data);
		
	};
	
	/**
	 * Error codes for JSON-RPC. See: 
	 */
	enum JsonRpcErrorCode {
		Parse = -32700,
		InvalidRequest = -32600,
		MethodNotFound = -32601,
		InvalidParams = -32602,
		InternalError = -32603,
	}
	
}

new JsonRpcError(JsonRpcErrorCode.Parse, "");
