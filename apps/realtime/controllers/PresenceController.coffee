redis = require 'redis'
async = require 'async'

Controller        = require './framework/Controller'

db                 = require 'lib/db'
ProjectResult      = require 'lib/results/ProjectResult'
RealtimeUserResult = require 'lib/results/RealtimeUserResult'

module.exports = class PresenceController extends Controller
	
	@handlers:
		'whoami':'_onWhoAmI'
		'setProject':'_onSetProject'
		'disconnect':'_onDisconnect'
		'setIdle':'_onIdle'
		'setActive':'_onActive'
		'chat':'_onChat'
		
	onConnection: (user, socket) ->
		super
		debug 'status', 'join'
		socket.join ''

	
	constructor: ->
		super
		
	_broadcastPresence: (projectId, userId, presenceState, since) ->
		debug 'presence', "_broadcastPresence:", projectId, userId, presenceState
		
		message = {presenceState, userId, since}
		@send projectId, 'presence', message
		

	# _broadcastChat: (projectId, userId, message) ->
		# debug 'presence', "broadcast chat message '#{message}' to project #{projectId} from user #{userId}"
		# for socketId, user of @channels[projectId]
			# @io.sockets.socket(socketId).emit 'presence',
				# email: userEmail
				# message: message
		

	_onWhoAmI: (context, callback) ->
		{user,socket} = context
		callback? new RealtimeUserResult(user)

			
	_onSetProject: (context, projectId, callback) ->
		{user,socket} = context
		debug 'presence', "#{user.username} wants to join project #{projectId}"
		if !projectId.match /[a-f0-9]+/
			logError 'presence', "user #{user.email} trying to connect to invalid project #{projectId}!"
			return
			
		db.projects.getById projectId, (err, project) =>
			# debug 'presence', 'got project?', err, project
			if err?
				logError "error getting projects", err
				return
				
			project = new ProjectResult project
				
			unless project.public or _.contains(project.members, String user._id)
				# user not a member
				debug 'presence', 'setProject Failed', user._id, 'tried joining project with members', project.members, @io.sockets.clients(projectId)
				for member in project.members
					debug 'presence', member, typeof member, user._id, typeof user._id
				return callback 401

			socket.join(projectId) #joins the project room
			
			
			@_changeUserState context, 'active'
			
			async.map(
				@io.sockets.clients(projectId)
				(socket,callback) => 
					debug 'presence', 'getting user for setproj', socket.id
					socket.get 'user', (err, u) =>
						if err?
							logError 'error getting user for setproj', socket.id
							return callback err
						
						debug 'presence', 'got user for setproj', socket.id, u
						
						callback null, JSON.parse u
						
				(err, users) =>
					debug 'presence', 'setProject got users', err, users
					if err then return logError 'error getting users out of socket store', err
					usersResult = {}
					for u in users
						unless u? then continue
						usersResult[u._id] = new RealtimeUserResult(u)
			
					debug 'presence', 'informing', user.username, 'of users', usersResult
			
					socket.emit 'users', usersResult
			)


	_onDisconnect: (context) ->
		{user,socket} = context
		debug 'status', 'leave'
		socket.leave ''
		debug 'presence', "#{user.email} disconnected", true
		
		@_changeUserState context, 'offline'


	_onIdle: (context, since) ->
		{user,socket} = context
		debug 'presence', "#{user.email} is idle"
		@_changeUserState context, 'idle'


	_onActive: (context) ->
		{user,socket} = context
		debug 'presence', "#{user.email} is active again"
		@_changeUserState context, 'active'

	_onChat: (context, projectId, message, toUser = null) ->
		{user,socket} = context
		if toUser
			@getUser toUser, (err, user) =>
				@io.socket.socket.send user.socket {private:true, from:user._id, message}
		else
			@send projectId, 'chat', {from:user._id, message}

	# change the users state and decide whether to broadcast new user state based on multiple connections
	_changeUserState: (context, state) ->
		{user,socket} = context
		
		debug 'presence', 'changeUserState', user.username, state
		
		user.presenceState = state
		user.since = new Date().getTime()
		
		socket.set 'user', JSON.stringify(user), (err) =>
		
			# debug 'presence', 'rooms', @io.sockets.manager.roomClients
			
			for projectId of @io.sockets.manager.roomClients[socket.id]
				do (projectId, user) =>
					if not projectId? or projectId.trim() in ['', '/'] then return
					
					debug 'presence', 'changeUserState projects', context.user.username, state, projectId
					projectId = projectId.substr 1
					usersInRoom = Object.keys(@io.sockets.clients(projectId)).length
					
					statesByRank = {offline:1, idle:2, active:3}
					
					next = =>
						debug 'presence', 'next'.white, projectId, user._id, user.presenceState, user.since
						@_broadcastPresence projectId, user._id, user.presenceState, user.since
		
					if user.presenceState is 'active' then return next()
						
					async.map(
						@io.sockets.clients(projectId)
						(socket, callback) => #callback(null, true) means broadcast ok, false means dont broadcast
							socket.get 'user', (err, socketUser) =>
								if err? then return callback err
								unless socketUser?
									logError 'no socketUser found for socket', socket?.id
									return callback()
									
								socketUser = JSON.parse socketUser
								debug 'presence', 'user check'.white, user, socketUser
								debug(
									'presence'
									'broadcast check'.white
									socket.id
									user.socketId
									socket.id is user.socketId
									statesByRank[user.presenceState]
									socketUser.presenceState
									statesByRank[socketUser.presenceState]
									statesByRank[user.presenceState] < statesByRank[socketUser.presenceState]
									false
								)
								if socket.id is user.socketId
									debug 'presence', 'same socket'.white
									return callback null, true
								debug( 
									'presence'
									'same user?'.white
									socketUser._id
									user._id
									String(socketUser._id) is String(user._id)
									false
								)
								if String(socketUser._id) is String(user._id) and statesByRank[user.presenceState] < statesByRank[socketUser.presenceState]
									debug 'presence', 'not broadcasting'.white
									return callback null, false
								else return callback null, true
						(err, results) =>
							debug 'presence', 'changeUserState results'.white, results 
							for result in results
								if result is false then return
							next()
					)		
				
				
		
		
		
		
		
		
		
		
		
