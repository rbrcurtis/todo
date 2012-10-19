Result = require './Result'

class PageResult extends Result
	
	constructor: (docs, meta, convert) ->
		super
		@meta    = meta
		@[index] = convert(doc) for doc, index in docs
		@length  = docs.length
	
	toJSON: ->
		_.toArray this

module.exports = PageResult
