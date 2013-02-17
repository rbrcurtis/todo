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
			unless user? then return callback? err, user
			for token in user.tokens
				debug 'auth', 'token', token, false
				if token?.expires?.getTime() < Date.now()
					db.tokens.remove token
		
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

