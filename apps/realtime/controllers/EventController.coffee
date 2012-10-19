util = require 'util'

Controller = require './framework/Controller'

MessageFactory = require './util/MessageFactory'
messageBus     = require 'lib/messageBus'
db             = require 'lib/db'

ActivityResult = require 'lib/results/ActivityResult'

module.exports = class EventController extends Controller
	
	@handlers:{}
	
	constructor: ->
		super
		@queue = messageBus.events
		@messageFactory = new MessageFactory()
		@queue.subscribe @_onMessage
		

	onConnection:(user) ->
		super

	_onMessage: (msg) =>
		debug 'rtevents', 'got message', msg
		
		if msg.project?
			if msg.documentType is 'Rank'
				@send msg.project, 'rerank', msg.document
			else
				db.projects.getById msg.project, (err, project) =>
	
					msg = new ActivityResult msg, project
			
					debug 'rtevents', "broadcasting event", msg
					@send msg.project, 'action', msg
				
