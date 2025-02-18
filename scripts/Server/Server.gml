
/**
 * A server for the game.
 * 
 * @param {Struct.NetworkServer} networkServer The underlying server controller on the network.
 */
function Server(networkServer) constructor {
	
	CLASS_LOG;
	
	self.jsonRpc = new JsonRpc(ServerProcedures.procedureList, ClientProcedures.procedureList);
	self.clients = [];
	
	self.networkServer = networkServer;
	self.networkServer.events.on("connect", method(self, self.onNetConnect));
	self.networkServer.events.on("disconnect", method(self, self.onNetDisconnect));
	self.networkServer.events.on("data", method(self, self.onNetData));
	
	/**
	 * Begins listening on the network for clients.
	 * Returns whether the operation was successful.
	 * 
	 * @returns {Bool}
	 */
	static listen = function() {
		return self.networkServer.listen();
	}
	
	/**
	 * Dispose of this server.
	 * This method **MUST** be called to clean up the resources used by this server.
	 */
	static dispose = function() {
		self.networkServer.dispose();
	};
	
	/**
	 * Call a remote procedure on a given client.
	 * 
	 * @private
	 * @param {Id.Socket} client The client to call the procedure on.
	 * @param {Struct.JsonRpcProcedure} procedure The procedure to call
	 * @param {Struct.Message} params The parameters for the procedure.
	 * @param {Function} callback `(result: T|Undefined, error: E|Undefined) -> Undefined` \| A function to be executed upon receiving a response to this request, unless this is a notification.
	 */
	static call = function(client, procedure, params, callback) {
		self.networkServer.sendJson(client, self.jsonRpc.createRequest(procedure, params, callback));
	};
	
	/**
	 * Respond to a remote procedure call from the given client, with the specified response data.
	 * 
	 * @private
	 * @param {Id.Socket} client The client to reply to.
	 * @param {Struct.JsonRpcIncomingRequest} request The request for which we are responding to.
	 * @param {Struct.Message} response The response data to send.
	 */
	static respond = function(client, request, response) {
		self.networkServer.sendJson(client, self.jsonRpc.createResponse(request, response));
	};
	
	/**
	 * Handle a client's connection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onNetConnect = function(client) {
		log.info($"New connection from `{client}`");
		array_push(self.clients, client);
	};
	
	/**
	 * Handle a client's disconnection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onNetDisconnect = function(client) {
		log.debug($"`{client}` is disconnecting");
		array_delete(self.clients, array_get_index(self.clients, client), 1);
	};
	
	/**
	 * Handle incoming data from a client.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 * @param {Id.Buffer} buffer
	 */
	static onNetData = function(client, buffer) {
		
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Packet from client `{client}`: `{text}`");
		
		try {
			json = json_parse(text);
		} catch (_) {
			log.error(new Err("TODO: Failed to parse inbound message from client!"));
			return;
		}
		
		var request;
		
		try {
			request = self.jsonRpc.handleIncoming(json);
		} catch (err) {
			log.error(new Err("Error whilst handling incoming request", err));
			return;
		}
		
		if (!is_instanceof(request, JsonRpcIncomingRequest)) {
			return;
		}
		
		var procedureHandler = procedureHandlers[$ request.procedure.name];
		procedureHandler(client, request, request.params);
		
	};
	
	/**
	 * @param {Id.Socket} client
	 * @param {Struct.JsonRpcIncomingRequest} request
	 * @param {Struct.ClientJoinInfo} params
	 */
	static onJoin = function(client, request, params) {
		
		var desiredUsername = params.desiredUsername;
		log.info($"Client `{client}` joining with username {desiredUsername}");
		
		self.respond(client, request, new ServerJoinInfo(
			client,
			self.clients
		));
		
	};
	
	/**
	 * List of registered handlers for procedures on the server.
	 * @ignore
	 */
	static procedureHandlers = {};
	
	if (struct_names_count(procedureHandlers) == 0) {
		
		procedureHandlers[$ ServerProc.join.name] = self.onJoin;
		
		// Ensure all procedures have been registered.
		Assert.eq(struct_names_count(procedureHandlers), array_length(ServerProc.procedureList));
		
	}
	
}

/**
 * Shorthand macro for accessing the list of server procedures.
 * 
 * This basically just exists because the GameMaker IDE's Code Editor 2 refuses to autocomplete constructor names
 * if the previously typed keyword was not `new`.
 */
#macro ServerProc ServerProcedures

/**
 * The list of procedures on a game server.
 */
function ServerProcedures() constructor {
	
	/**
	 * Clients call this to inform the server of their configuration. In response,
	 * the server informs them of the client list, and their unique ID in the server.
	 */
	static join = new JsonRpcProcedure("join", ClientJoinInfo, ServerJoinInfo);
	
	/**
	 * The full list of procedures, to register against.
	 */
	static procedureList = [
		join
	];
	
}

new ServerProcedures();
