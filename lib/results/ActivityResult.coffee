DocumentResult = require './framework/DocumentResult'

module.exports = class ActivityResult extends DocumentResult

	constructor: (activity) ->
		debug 'activityresult', 'new activityresult', activity
		super
		@created = activity.created
		@user = if activity.user then new UserResult activity.user else null
		@request = activity.request
		@type = activity.type
		@documentType = activity.documentType
		@documentId = activity.documentId
		ResultClass = require "lib/results/#{activity.documentType}Result"
		@document = new ResultClass activity.document
		@previous = activity.previous or null
		
		@metadata = {}
		
		# convert all meta data into result objects
		for type,dict of activity.meta
			ResultClass = require "lib/results/#{type}Result"
			@metadata[type] = {}
			for id, obj of dict
				@metadata[type][id] = new ResultClass obj
		

		{@summary,@details,@action} = @setActionContent activity
		
		debug 'activityresult', 'ActivityResult created', @
		
		

	setActionContent: (activity) ->
		debug 'activityresult', 'setActionContent', @id
		try
			content = @_determineAction activity
		catch e
			logError e

		unless content?
			text = "#{activity.documentType} #{activity.type}"
			content =
				summary:text
				details:text
				action:activity.documentType.toLowerCase()+activity.type.substr(0,1).toUpperCase()+activity.type.substr(1)
				
		activity.summary = content.summary
		activity.details = content.details
		activity.action = content.action
		return activity

	_determineAction: (activity) ->
		return {
			summary: 'unknown'
			details: 'unknown'
			action:  'unknown'
		}
			
