crypto = require 'crypto'

mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
Mixed = mongoose.Schema.Types.Mixed

auth = require 'lib/auth'
plugins = require './plugins'

TokenSchema = require('./Token').schema

UserSchema = new mongoose.Schema
	_id:
		type: ObjectId
	
	name: String
	
	username:
		type: String
		lowercase: true
		index:
			unique: true
			background: true

	email:
		type: String
		lowercase: true
		index:
			unique: true
			background: true

	password:
		type: String
		set: (value) -> auth.hashPassword(value)

	tokens:
		type: [TokenSchema]
		
	accessed:
		type: Date


UserSchema.documentType = 'User'
UserSchema.strict = true
UserSchema.plugin(plugins.changeTracking)
UserSchema.plugin(plugins.timestamp)

_.extend UserSchema.methods,
	setPreference: (key, value) ->
		@preferences[key] = value
		@markModified("preferences.#{key}")
	hashPassword: (password) ->
		return auth.hashPassword password

module.exports = mongoose.model 'User', UserSchema
