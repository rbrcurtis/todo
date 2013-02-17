async = require 'async'

DocumentRepository = require './framework/DocumentRepository'
User = require '../models/User'

db = require 'lib/db'
uuid = require 'lib/uuid'
error = require 'lib/error'
ObjectId = require('mongoose').Types.ObjectId

module.exports = new class UserRepository extends DocumentRepository
	
	_model: User
	
	getByEmail: (email, options, callback) ->
		@get {email}, options, callback
		
	getByUsername: (username, options, callback) ->
		@get {username}, options, callback
		
	getByToken: (token, options, callback) ->
		callback = @_findCallback arguments...
		unless token then return callback? null, null
		unless token.length > 24
			log 'invalid token', token
			return callback? null, null
		userId = token.substr 0,24
		tokenId = token.substr 24
		@getById userId, (err, user) =>
			debug 'auth', 'get by token', userId, user
			unless user? then return callback? err, user

			debug 'auth', 'reducing tokens', user.tokens

			async.reduce user.tokens, user, 
				(user, token, callback) =>
					debug 'auth', 'token', token, token?.expires?.getTime() < Date.now()
					if token?.expires?.getTime() < Date.now()
						return db.tokens.remove token, callback
					else return callback(null, user)
				(err, user) =>
					debug 'auth', 'reduced tokens', user?.tokens
					unless user? then return callback()
					
					if user.tokens.id(tokenId) then return callback null, user
					else return callback null, null

	findByProject: (project, options, callback) ->
		members = {}
		for role in project.roles
			for member in role.members
				members[member] = true
		@find {_id: {$in: Object.keys(members)}}, options, callback
		
	getWorkspaceMembers: (workspace, options, callback) ->
		db.projects.findByWorkspace workspace._id, (err, projects) =>
			if err then return callback err

			members = {}
			for user in workspace.owners
				members[user] = true
				
			for project in projects
				for role in project.roles
					for member in role.members
						members[member] = true
						
			@find {_id: {$in: Object.keys(members)}}, options, callback
			
	create: (data, callback) ->
		user = new User
			_id: uuid.generate()
			name: data.name
			email: data.email
			username: data.username
			password: data.password
			token: data.token
		@save user, callback

