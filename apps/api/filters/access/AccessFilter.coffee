Filter = require '../framework/Filter'

db = require 'lib/db'
error = require 'lib/error'

class AccessFilter extends Filter
	
	levels:
		read:  1
		write: 2
		admin: 3
	
	before: (success, failure) ->
		
		
		if not @user? then return failure error.unauthorized()
		@getProjectForRequest (err, project) =>
			if err?         then return failure err
			if not project? then return failure error.notFound()
			if @_hasAccess(project.roles)
				return success()
			else
				return failure error.forbidden()
	
	getProjectForRequest: (callback) ->
		if @request.context.project?
			return callback null, @request.context.project
		else if @request.context.phase?
			db.projects.get {'phases._id': @request.context.phase}, callback
		else if @request.context.card?
			db.cards.getById @request.context.card, (err, card) ->
				if err? then return callback(err, null)
				if not card? then return callback(null, null)
				db.projects.getById card.project, callback
	
	_hasAccess: (roles) ->
		
		if @user.siteAdmin then return true
		
		demanded = @levels[@requiredAccess]
		highest = 0
		for role in roles
			if role.hasMember @user._id
				highest = Math.max(highest, @levels[role.access])
		return highest >= demanded

module.exports = AccessFilter