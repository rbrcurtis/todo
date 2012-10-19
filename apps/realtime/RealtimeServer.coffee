fs = require 'fs'
util = require 'util'
async = require 'async'
events = require 'events'
express = require 'express'
connect = require 'connect'
socketio = require 'socket.io'

db = require 'lib/db'
uuid = require 'lib/uuid'

UserResult = require 'lib/results/UserResult'

PresenceController = require './controllers/PresenceController'
EventController = require './controllers/EventController'
RallyUserController = require './controllers/RallyUserController'

module.exports = class RealtimeServer
	
	@controllers: [
		PresenceController
		EventController
		RallyUserController
	]
	
	constructor: ->
		opts = {}
		if CONFIG.ssl.enabled
			opts.key = fs.readFileSync CONFIG.ssl.key
			opts.cert = fs.readFileSync CONFIG.ssl.cert
		@app = express.createServer opts

	start: ->
		@app.listen CONFIG.realtime.port, =>
			addr = @app.address()
			log "listening on http://#{addr.address}:#{addr.port}"
			
		@io = socketio.listen @app
		@io.set 'log level', 0
		
		redisPub = redisSub = redisClient = {host:CONFIG.redis.host}
		opts = {redisSub,redisPub,redisClient}
		@io.set 'store', new socketio.RedisStore opts
			
		@controllers = []
		for controller in @constructor.controllers
			@controllers.push new controller(@io)
		
		
		@io.set 'authorization', @_onAuthorization
		@io.sockets.on 'connection', @_onConnection
		
		setInterval @count, CONFIG.realtime.countInterval*1000
		
	count: =>
		async.map (val for key,val of @io.sockets.sockets),
			
			(socket, callback) =>socket.get 'user', callback
					
			(err, users) =>
				counted = {}
				if err then return logError err
				# unless users?.length then return log 'no users online'
				
				for user in users
					try
						unless user then continue
						user = JSON.parse user
						if user?.presenceState is 'active' then counted[user._id] = true
					catch e
					
				debug 'status', 'counted', Object.keys(@io.sockets.sockets).length, 'active', Object.keys(counted).length
				
				@io.get('store').cmd.setex("userCount:#{process.pid}", Math.floor(CONFIG.realtime.countInterval*.75), Object.keys(@io.sockets.sockets).length)
				@io.get('store').cmd.setex("userCountActive:#{process.pid}", Math.floor(CONFIG.realtime.countInterval*.75), Object.keys(counted).length)
		

	_onConnection: (socket) =>
		user = socket.handshake.user
		user.socketId = socket.id
		user.token = socket.handshake.token
		user.presenceState = 'active'
		user.since = new Date().getTime()
		
		debug 'realtime', "user #{user.username} connected", {token:socket.handshake.token,socketId:socket.id}, true
			
		socket.set 'user', JSON.stringify(user), (err) =>
			if err? then return logError 'error on user store for rt connection', user, error

			debug 'rtstore', 'user saved', socket.id, user
			
		for controller in @controllers
			controller.onConnection user, socket
	
	_onAuthorization: (data, accept) =>
		try
			cookies = if data.headers.cookie then connect.utils.parseCookie(data.headers.cookie) else {}
			data.token = cookies[CONFIG.cookies.auth.name]

			anon = ->
				uid = uuid.generate()
				return {_id:uid, name:'anonymous', username:'anonymous', email:"#{uid}@anonymous", token:null}

			unless data.token?
				debug 'realtime', "cookie not found", cookies
				if allowAnon
					data.user = anon()
					return accept(null, true)
				else
					return accept(null, false)
			else
				debug 'realtime', "found auth cookie", data.token
				
				db.users.getByToken data.token, {}, (err, user) =>
					if err?
						logError "error finding user", err
						return accept(null, false)
					if user?
						debug 'realtime', "authentication successful for user #{util.inspect user}", true
						data.user = JSON.parse JSON.stringify user
						return accept(null, true)
					else
						debug 'realtime', 'user not found'
						if allowAnon
							data.user = anon()
							return accept(null, true)
						else
							return accept(null, false)
				
		catch ex
			log "authentication exception: #{util.inspect ex}"
			return accept(null, false)
	
	
