Repository = require './Repository'

db = require 'lib/db'

module.exports = class EmbeddedDocumentRepository extends Repository
	
	constructor: ->
		super
		@setup()
		if not @parent? then throw new Error("#{@constructor.name} must define a parent repository")
		if not @_schema? then throw new Error("#{@constructor.name} must define a schema")
		if not @_path?   then throw new Error("#{@constructor.name} must define a path")
	
	getById: (id, callback) ->
		unless callback then return
		query = {}
		query["#{@_path}._id"] = id
		db[@parent].get query, (err, parent) =>
			if err? then return callback(err)
			if not parent? then return callback(null, null)
			callback null, @_getFromParent(parent, id)
	
	save: (document, callback) ->
		id = document._id
		db[@parent].save document.parent, (err, parent) =>
			if err? then callback(err)
			callback null, @_getFromParent(parent, id)
	
	remove: (document, callback) ->
		document.parent[@_path].remove(document)
		db[@parent].save document.parent, callback
	
	_getFromParent: (parent, id) -> parent.get(@_path).id(id)

