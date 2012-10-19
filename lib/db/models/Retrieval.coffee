crypto = require 'crypto'

mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
Mixed    = mongoose.Schema.Types.Mixed


RetrievalSchema = new mongoose.Schema

	_id: ObjectId
	
	created:
		type: Date
		default: Date.now()
		index:
			background: true
			
	user: 
		type: ObjectId
		required: true
		index:
			background: true
			required: true

RetrievalSchema.documentType = 'Retrieval'
RetrievalSchema.strict = true

module.exports = mongoose.model 'Retrieval', RetrievalSchema
