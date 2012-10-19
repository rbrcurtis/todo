async = require 'async'

messageBus = require 'lib/messageBus'
db = require 'lib/db'
ActivityResult = require 'lib/results/ActivityResult'

class Responder
	
	constructor: (@request) ->
	
	success: (result) ->
		@request.result = result
		@_finish 'success'
	
	failure: (err) ->
		@request.error = err
		@_finish 'failure'

	_finish: (status) ->
		finished = new Date()
		
		_.extend @request,
			status:   status
			finished: finished
			duration: finished.getTime() - @request.started.getTime()
		
		async.map @request.activities, @_createActivity, (err, activities) ->
			logError err if err?
		
		# messageBus.requests.publish @request
	
	_createActivity: (activity, callback) =>
		db.activities.save activity, (err, activity) ->
			if err? then callback(err)
			messageBus.activities.publish {activity,clientReqId:@request.clientReqId}
			callback null, activity

module.exports = Responder
