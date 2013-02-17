mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

plugins = require './plugins'

TokenSchema = new mongoose.Schema
	_id: ObjectId
	expires: Date

TokenSchema.documentType = 'Token'
TokenSchema.strict = true

exports.schema = TokenSchema