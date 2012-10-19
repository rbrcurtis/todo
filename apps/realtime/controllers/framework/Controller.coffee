

module.exports = class Controller
	
	# 'message type':'handler'
	# handlers should all be of the format (context, arguments)
	@handlers: {}
	
	constructor: (@io) ->
		
	onConnection: (user, socket) ->
			
		for message, handler of @constructor.handlers
			debug 'realtime', 'handle'.yellow, message, handler
			do (message, handler) =>
				socket.on message, =>
					@[handler].apply @, [{user,socket}, arguments...]
					
	send: (projectId, type, message) ->
		usersInRoom = Object.keys(@io.sockets.clients(projectId)).length
		
		debug 'rtsend', "@send called for projectId", projectId, "type", type, "which has", usersInRoom, "users on this RT server"
		
		if usersInRoom is 0 then return
		
		debug 'rtsend', 'sending', message
		
		for key,val of @io.sockets.sockets
			debug 'realtime', key,'=', typeof val
		@io.sockets.in(projectId).emit type, message
