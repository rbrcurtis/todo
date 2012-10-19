async = require 'async'
db = require 'lib/db'
messageBus = require 'lib/messageBus'

module.exports = new class Inviter
	
	invitePending: ->
		db.invites.find {active: false}, (err, invites) =>
			if err then return logError err
			async.forEachSeries invites,
				(invite, callback) =>
					invite.active = true
					invite.madeActive = new Date()
					@_sendEmail(invite)
					invite.save callback
				(err) =>
					if err then logError err
					log invites.length, 'sent'
					
	
	inviteList: (emails) ->
		async.forEachSeries emails,
			(invitee, callback) =>
				db.users.find {email:invitee}, (err, users) =>
					if users.length
						log invitee, 'already has an account'
						return callback()
						
					db.invites.find {email:invitee}, (err, invite) =>
						if invite.length
							log 'invite already created for', invitee #, 'sending new email'
							# @_sendEmail invite[0]
							return callback()
							
						db.invites.create {invitee:invitee, active:true}, (err, invite) =>
							if err then return callback err
							log 'invite created for', invitee
							@_sendEmail invite
							return callback()
			(err) =>
				if err then logError err
				log "all invites sent"
		
	_sendEmail: (invite) ->
		log 'queueing invite for', invite.email
		invite = JSON.parse JSON.stringify invite
		invite.type = 'beta'
		messageBus.invites.publish invite
