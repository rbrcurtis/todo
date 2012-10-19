crypto = require 'crypto'

mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
Mixed = mongoose.Schema.Types.Mixed
ItemSchema = require('./Item').schema
auth = require 'lib/auth'
plugins = require './plugins'

ListSchema = new mongoose.Schema
	
	_id: ObjectId
	
	name: String

	items: [ItemSchema]
	default: []
	

ListSchema.documentType = 'List'
ListSchema.strict = true
ListSchema.plugin(plugins.changeTracking)
ListSchema.plugin(plugins.timestamp)

_.extend ListSchema.methods,
	setPreference: (key, value) ->
		@preferences[key] = value
		@markModified("preferences.#{key}")
	hashPassword: (password) ->
		return auth.hashPassword password

module.exports = mongoose.model 'List', ListSchema
