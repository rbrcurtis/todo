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
		@get {token}, options, callback
	
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

