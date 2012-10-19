Result = require './Result'

class DocumentResult extends Result
	
	constructor: (document) ->
		super
		@id = if document._id then String(document._id) else null
		
		if document.created?
			@created = document.created
			
		if document.updated?
			@updated = document.updated
			# @meta.lastModified = document.updated.toUTCString()

module.exports = DocumentResult
