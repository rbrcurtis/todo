crypto = require 'crypto'

Repository = require './Repository'
error = require 'lib/error'


module.exports = class DocumentRepository extends Repository
	
	constructor: ->
		super
		@_schema = @_model.schema
		
	hash: (str) ->
		return crypto.createHash('md5').update(str).digest('hex')
	
	get: (query, fields, options, callback) ->
		@_model.findOne(query, fields, options, callback)
	
	getById: (id, options, callback) ->
		@get({_id:id}, options, callback)
	
	getByRef: (ref, options, callback) ->
		id = @_getIdFromRef ref
		unless id? then return callback error.badRequest()
		@getById(id, options, callback)
	
	find: (query, fields, options, callback) ->
		@_model.find(query, fields, options, callback)
	
	findAllById: (ids, fields, options, callback) ->
		@_model.find({_id: { $in: ids }}, fields, options, callback)
	
	where: ->
		@_model.where.apply @_model, arguments
	
	save: (document, callback) ->
		document.save(callback)
	
	remove: (document, callback) ->
		document.remove(callback)
	
	_getIdFromRef: (ref) ->
		if _.isString(ref) then return ref
		if _.isObject(ref) and ref.id? then return ref.id
		return undefined

	_findCallback: (args...) ->
		return _.find args, (arg) -> typeof arg is 'function'

