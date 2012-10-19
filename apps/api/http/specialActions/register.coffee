async = require 'async'

db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'
validate = require 'lib/validate'
messageBus = require 'lib/messageBus'

module.exports = (req, res, next) ->
	
	new Registerer().register req, res, next
	
class Registerer
	
	register: (req, res, next) ->
		debug 'register', 'register start', @username
		
		@username = username = req.param 'username'
		display     = req.param 'display'
		email       = req.param 'email'
		password    = req.param 'password'
		
		debug 'register', 'paramed', {username, display, email, password}
		
		for key, val of {username, display, email, password}
			debug 'register', 'checking', key, val
			unless val? then return next error.badRequest("#{key} is missing")
			unless (err = validate[key](val)) is true then return next error.badRequest(err)
			
		username = username.trim().toLowerCase()
		display = display.trim()
		email = email.trim().toLowerCase()
		password = password.trim()


		async.waterfall(
			[
				(callback) =>
					inviteId = req.param('invite')
					debug 'register', 'handle invite code', inviteId, email
					
					unless inviteId or email.match /rallydev.com/ then return callback error.badRequest "I'm sorry, the beta isn't open yet, but check back soon!"
					unless inviteId then return callback()
					
					db.invites.getById inviteId, (err, @invite) =>
						debug 'register', 'got invite', err, @invite
						
						if err then return callback err
						
						unless @invite then return callback error.badRequest "I'm sorry, that is not a valid invite code."
						
						unless @invite.active then return callback error.badRequest "I'm sorry, this invite code is not active yet."
						
						unless @invite.email.toLowerCase() is email then return callback error.badRequest "The specified email address does not match the invite code."

						if @invite.used? then return callback error.badRequest "I'm sorry, this invite code has been used.  Try recovering your password."
						
						return callback()
				
				(callback) =>
					debug 'register', 'check for duplicate user'
					query = db.users.get().or [
						{username: username},
						{email:    email}
					]
					
					query.exec (err, user) =>
						debug 'register', 'queried for duplicate', err, user
						if err? then return callback(err)
						
						if user?
							log 'user exists'
							if user.username is username then return callback error.badRequest("A user with that username already exists")
							if user.email is email then return callback error.badRequest("A user with that email already exists.  Maybe try recovering your password?")
							else
								return callback error.server("user exists for register but I have no idea why #{user}")
						
						else callback()
						
				(callback) =>
					debug 'register', 'creating user'
					
					userObj = {
						username,
						email,
						name: display
						password
						token: uuid.generate()
					}
					
					db.users.create userObj, (err, user) =>
						if err
							logError 'error on user create', err
							return callback err
							
						console.log "User created: #{JSON.stringify user}"
						messageBus.welcome.publish user
						
						capped = username.substr(0,1).toUpperCase()+username.substr(1).toLowerCase()
						
						db.workspaces.create user, name:"#{capped}'s Projects", (err, workspace) =>
							if err
								logError 'error on workspace create', err
								return callback err
							
							
							db.projects.create user, workspace.id, name:"First Project", (err, project) =>
								if err
									logError 'error on project create', err
									return callback err
			
								
								res.cookie CONFIG.cookies.auth.name, user.token,
									expires: new Date(Date.now() + CONFIG.cookies.auth.lifetime)
									httpOnly: true
									domain: CONFIG.cookies.auth.domain
									
								res.send()
								
								if @invite?
									@invite.used = new Date()
									@invite.save (err) =>
										if err then logError 'error setting invite used date', err
						
						
						# handle invited project if specified else end
						unless @invite? and @invite.project? then return callback()
						
						db.projects.getById @invite.project, (err, project) =>
				
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
										
										# create activity
										db.users.getById @invite.sender, (err, sender) =>
											activity = db.activities.create role, 'update', sender, null, meta, project, null
										
											activity.save (err) =>
												if err then logError 'error creating activity', err
										
										debug 'register', 'role changes', role.changes
										debug 'register', 'user added', {project:project.id, role: role.name, user: user.username}
								if added
									debug 'register', 'changes', project.changes
									project.save callback
									break
								else
									logError "no role found to add new user to", @invite, user
									callback()
			]
			(err) => 
				debug 'register', 'ending', err
				if err then return next(err)
		)
		
						
