auth = require 'lib/auth'
db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'

PageResult = require 'lib/results/framework/PageResult'
WorkspaceResult = require 'lib/results/WorkspaceResult'

module.exports = (req, res, next) ->
	
	identity = req.param('username')
	password = req.param('password')
	
	unless identity? then return next error.badRequest()
	identity = identity.toLowerCase()
	
	query = db.users.get().or [
		{username: identity},
		{email:    identity}
	]
	
	query.exec (err, user) ->
		if err? then return next(err)
		if not user? then return next error.unauthorized()
		authed = auth.verifyPassword(password, user.password)
		
		if not authed #update password to new scheme
			authed = auth.verifyPasswordOld(password, user.password)
			log 'updating user to new password scheme', user.username
			if authed then user.password = password
			user.save()
			
		unless authed
			return next error.unauthorized()
		else
			db.workspaces.find owners:user._id, (err, subs) ->
				res.send new PageResult subs, {}, (sub) -> new WorkspaceResult sub