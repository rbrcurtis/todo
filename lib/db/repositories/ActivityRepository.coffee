
DocumentRepository = require './framework/DocumentRepository'
Activity = require '../models/Activity'

uuid = require 'lib/uuid'
db = require 'lib/db'

UserResult = require 'lib/results/UserResult'

ObjectId = require('mongodb').ObjectID

module.exports = new class ActivityRepository extends DocumentRepository

	_model: Activity
	
	_maxCount: 200
	
	save: (document, callback) ->
		if document.user?
			document.user._id = if document.user.id? then ObjectId document.user.id else null
			delete document.user.id
			
		super
	
	get: (query, options, callback) ->
		if query?.project?
			query.shardKey = @hash query.project.toString()
			debug 'sharding', 'activity:shardKey used'.green, query
		else
			debug 'sharding', 'activity:shardKey NOT used'.red, query
		super
		
	find: (query, fields, options, callback) ->
		debug 'activity', 'find', arguments...
		if query?.project? and query.project.toString().match /[0-9a-z]{24}/
			query.shardKey = @hash query.project.toString()
			debug 'sharding', 'activity:shardKey used'.green, query
		else
			debug 'sharding', 'activity:shardKey NOT used'.red, query
		super

	getRecentByProjectId: (projectId, options, callback) ->
		debug 'activity', 'repo', 'getRecentByProjectId', arguments...
		@find {project:projectId}, null, {sort:{created:-1},limit:40}, callback

	getByCardId: (projectId, cardId, options, callback) ->
		@find {project:projectId, card:cardId}, null, {sort:{created:-1}}, callback
	
	getSinceByProjectId: (projectId, since, options, callback) ->
		since = +since
		date = new Date()
		date.setTime(since)
		
		query = {project:projectId, created:{$gt:date}}
		
		Activity.count query, (err, count) =>
			if err? then return callback err
			
			if count > @_maxCount then return callback 412
			
			@find query, callback

	getBeforeByProjectId: (projectId, before, options, callback) ->
		before = +before
		date = new Date()
		date.setTime(before)
		
		query = {project:projectId, created:{$lt:date}}
			
		@find query, null, {sort:{created:-1},limit:40}, callback


	###
	create an activity
	this is unlike other repo creates in that it does not save the activity to the store.  
	activities that get added to the request (@request.addUpdated() for example) will get saved
	by the responder when the request finishes 

	@param document a MONGOOSE MODEL.  You can hack up a fake by adding schemaType.documentType as a property.
	@param type ENUM 'update', 'create', 'delete'
	@param user model
	@param request
	@param meta
	@param project model or id
	@param card model

	###
	create: (document, type, user = null, request = null, meta = null, project = null, card = null) ->
		debug 'activity', 'creating activity', {document, type, user, meta}
		
		if user? then user = new UserResult(user)

		if card?._id?
			meta ?= {}
			meta.Card ?= {}
			meta.Card[String(card._id)] = card
		
		activity = new Activity
			_id:          uuid.generate()
			type:         type
			created:      new Date()
			documentType: document.schema.documentType
			documentId:   document._id
			document:     document.toJSON?() or document
			previous:     document.changes ? undefined
			meta:         meta ? undefined
			request:      request
			user:         user
			project:      project ? document.project ? undefined
			card:         card?._id or undefined
			
		unless activity.shardKey then activity.shardKey = 'undefined'
			
		debug 'activity', 'created', {activity}
		
		delete document.changes
			
		return activity