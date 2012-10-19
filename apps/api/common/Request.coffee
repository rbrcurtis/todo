os = require 'os'
uuid = require 'lib/uuid'
db = require 'lib/db'

UserResult = require 'lib/results/UserResult'

module.exports = class Request
	
	constructor: ->
		@id = uuid.generate()
		@auth = 'none'
		@status = 'pending'
		@started = new Date()
		@params = {}
		@context = {}
		@activities = []
		@process =
			platform: process.platform
			arch:     process.arch
			pid:      process.pid
			uptime:   process.uptime()
			machine:  os.hostname()
			loadavg:  os.loadavg()
			totalmem: os.totalmem()
			freemem:  os.freemem()
	
	addCreated: (document, user, meta) ->
		a = @_createActivity(document, 'create', user, meta)
		@activities.push a
		return a
	
	addUpdated: (document, user, meta) ->
		for key, val of document?.changes
			if document.changes[key] is document[key] then delete document.changes[key]
		unless document?.changes and Object.keys(document.changes).length then return
		debug 'activity', 'changes', document.changes
		a = @_createActivity(document, 'update', user, meta)
		@activities.push a
		return a
	
	addDeleted: (document, user, meta) ->
		a = @_createActivity(document, 'delete', user, meta)
		@activities.push a
		return a
		
	# create an activity which will get put on the rabbit queue. *DO NOT* do anything async in here
	#
	# @param document
	# @param type
	# @param user (optional, defaults to the user making the request)
	#
	# @return new activity
	_createActivity: (document, type, user = @user, meta) ->
		unless document? and type? then return
		project = @context.project ? document.project ? undefined
		if type is 'Project' then project = document._id
		
		card =  @context.card or if document.schema.documentType is 'Card' then document
		if card? then card = {_id:card._id, number:card.number}
		
		return db.activities.create document, type, user, @id, meta, project, card
