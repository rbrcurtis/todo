EmbeddedDocumentRepository = require './framework/EmbeddedDocumentRepository'
User = require '../models/User'
ApiKeySchema = require('../models/ApiKey').schema

db = require 'lib/db'
uuid = require 'lib/uuid'

module.exports = new class ApiKeyRepository extends EmbeddedDocumentRepository
	
	setup: ->
		@_schema = ApiKeySchema
		@parent = 'users'
		@_path   = 'tokens'

	create: (user, properties, callback) ->
	
		id = uuid.generate()
		
		user.tokens.push
			_id:     id
			expires: expires = new Date(Date.now() + CONFIG.cookies.auth.lifetime)

		db[@parent].save user, (err, user) =>
			if err? then return callback(err, null)
			callback null, user.tokens.id(id)

