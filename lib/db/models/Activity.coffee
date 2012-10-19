crypto = require 'crypto'

mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
Mixed = mongoose.Schema.Types.Mixed

enums = require 'lib/enums'
plugins = require './plugins'

ActivitySchema = new mongoose.Schema
	_id: ObjectId
	
	created:
		type: Date
		default: new Date()
		index: 
			background:	true
	
	user:
		type: Mixed
		
	list:
		type: ObjectId
		set: (value) -> @shardKey = value; return value
		index: 
			background:	true
		
	item:
		type: ObjectId
	
	request:
		type: ObjectId
		index: 
			background:	true
			
	type: String
	
	documentType: String
	
	documentId: ObjectId
	
	# unaltered document. do not denormalize anything in this doc so that we can replay activities when needed without multiple steps
	document:	Mixed
	
	# unaltered/normalized diffs.  do not denormalize
	previous:	Mixed
	
	# this should be a assoc array of meta.Type[String(id)] = Document. IE meta.Card[abc123] = Card abc123
	meta: Mixed

ActivitySchema.documentType = 'Activity'
ActivitySchema.strict = true
ActivitySchema.shardkey = {shardKey:1}
ActivitySchema.index({documentType:1, documentId:1}, {background:true})

module.exports = mongoose.model 'Activity', ActivitySchema
