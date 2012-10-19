auth = require 'lib/auth'
db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'

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
			sendCookie = ->
				res.cookie CONFIG.cookies.auth.name, user.token,
					expires: new Date(Date.now() + CONFIG.cookies.auth.lifetime)
					httpOnly: true
					domain: CONFIG.cookies.auth.domain
				res.send()
				
			if user.token then sendCookie()
			else 
				user.token = uuid.generate()
				db.users.save user, (err) ->
				if err? then return next(err)
				sendCookie()
				
			# handle invite code
			
			if inviteId = req.param('invite')
				db.invites.getById inviteId, (err, invite) =>
					if err then logError 'couldnt get invite for user', user._id, err
					unless invite then return logError 'invalid invite code', inviteId
					
					db.projects.getById invite.project, (err, project) =>
					
						added = false
						for role in project.roles
							if role.access is 'write'
								log 'members', role.members
								if role.members.indexOf(user.id)>=0
									debug 'invite', 'in there', user.username
									continue
								else
									added = true
									members = role.members.slice 0
									members.push user.id
									role.members = members
									meta = {}
									meta.User = {}
									meta.User[user.id] = user
									db.users.getById invite.sender, (err, sender) =>
										if err then return logError "error getting sender for invite"
										activity = db.activities.create role, "update", sender, null, meta, project
										activity.save (err) ->
											if err then return logError "error saving new activity", err
											debug 'invite', 'user added', {project:project.id, role: role.name, user: user.username}
							if added
								debug 'invite', 'changes', project.changes
								project.save (err) =>
									if err then return failure err
								break
						
							invite.used = new Date()
							invite.save()