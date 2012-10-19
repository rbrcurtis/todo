db = require 'lib/db'
Controller = require './framework/Controller'

module.exports = class EventController extends Controller
	
	@handlers:{
		'rally.initUser':'_onInit'
	}
	
	onConnection:(user) ->
		debug 'rally-user', if user.token then "#{user.token} connected..." else "unknown user connected."
		super

	_onInit: (context) =>
		user = context.user
		socket = context.socket

		db.projects.getAllowedProjectIds user, null, (err, ids) =>
			if err?
				logError "Failure to retrieve allowed projects for user with token #{user?.token}.", err 
				return 

			debug 'rally-user', 'Allowed to join the following rooms:', ids





