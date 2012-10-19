mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

plugins = require './plugins'

ItemSchema = new mongoose.Schema
	_id:   ObjectId
	owner: ObjectId
	text:  String

ItemSchema.documentType = 'Item'
ItemSchema.strict = true
ItemSchema.plugin(plugins.changeTracking)
ItemSchema.plugin(plugins.timestamp)

exports.schema = ItemSchema