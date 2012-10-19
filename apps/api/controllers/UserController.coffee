async = require 'async'

Controller = require './framework/Controller'
PageResult = require 'lib/results/framework/PageResult'
UserResult = require 'lib/results/UserResult'

db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'

module.exports = class UserController extends Controller
	
	get:
		before: ['setContext']
		handler: (success, failure) ->
			return success new UserResult(@request.context.user)
				
	remove:
		before: ['setContext','ensureIsSiteAdmin']
		handler: (success, failure) ->

			debug 'user', 'remove', user

			user = @request.context.user
			userId = String(user._id)
			meta = {}
			meta.User = {}
			meta.User[userId] = user

			async.waterfall [
				
					
				(callback) =>
					# remove as owner from cards
					db.cards.find owners:userId, (err, cards) =>
						if err then return callback err
					
						async.forEachSeries cards,
							(card, callback) =>
								card.owners = _.reject card.owners, (id) -> String(id) is String(userId)
								debug 'user', 'card.owners updated', card._id, card.owners, card.changes
								if card.changes? then @request.addUpdated card, null, meta
								card.save callback
							callback
						
				(callback) =>
					# remove from roles
					db.projects.find {'roles.members':userId}, (err, projects) =>
						if err then return callback err
						debug 'user', 'updating roles in', projects.length, 'projects'
						
						async.forEachSeries projects,
							(p, callback) =>
								for role, pos in p.roles
									role.members = _.reject role.members, (id) -> String(id) is String(userId)
									if role.changes? then @request.addUpdated role, null, meta
								p.save callback
							callback
							
				(callback) =>
					db.workspaces.find {owners:user}, callback
					
				(@subs, callback) =>
					debug 'user', 'remove subs', @subs
					@subs = _.reject @subs, (sub) -> return sub.owners.length > 1 #trim subs with other owners than this owner
					debug 'user', 'remove subs clean', @subs
					
					db.projects.find {workspace:$in:(s._id for s in @subs)}, callback
					
				(@projects, callback) =>
					debug 'user', 'remove projects', ({id:p._id, name:p.name} for p in @projects)
					
					db.cards.find {project:$in:(p._id for p in @projects)}, callback
					
				(@cards, callback) =>
					debug 'user', 'remove cards', (c.id for c in @cards)
					
					db.activities.find {project:$in:(p._id for p in @projects)}, callback
					
				(@activities, callback) =>
					debug 'user', 'remove activities', (a.id for a in @activities)
					
					callback()
					
				(callback) =>
					debug 'user', 'remove all'
					async.forEachSeries ([user].concat @subs, @projects, @cards, @activities),
						(model, callback) =>
							debug 'user', 'removing', model.schema.documentType, model._id
							unless model then callback()
							model.remove callback
						callback
						
					
				],
				(err) =>
					debug 'user', 'done removing user', userId, err
					if err then return failure err
					return success()
