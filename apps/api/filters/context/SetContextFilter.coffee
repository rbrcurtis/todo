Filter = require '../framework/Filter'

db = require 'lib/db'
error = require 'lib/error'

module.exports = class SetContextFilter extends Filter
	
	before: (success, failure) ->
		
		@request.context = {}
		
		checkNext = =>
			debug 'context', 'checkNext'

			if @request.params.user and not @request.context.user
				debug 'context', 'setting project'
				db.users.getById @request.params.user, (err, user) =>
					if err? then return failure err
					unless user then return failure error.notFound()
					_.extend @request.context, {user}
					return checkNext()

			else if @request.params.project and not @request.context.project
				debug 'context', 'setting project'
				db.projects.getById @request.params.project, (err, project) =>
					if err? then return failure err
					unless project then return failure error.notFound()
					_.extend @request.context, {project}
					return checkNext()
			
			else if @request.params.card and not @request.context.card
				debug 'context', 'setting card'
				db.cards.get {project:@request.context.project._id, _id:@request.params.card}, (err, card) =>
					if err? then return failure err
					unless card then return failure error.notFound()
					_.extend @request.context, {
						phase:_.find(@request.context.project.phases, (phase)->if String(phase.id) is String(card.phase) then true else false)
						card
					}
					return checkNext()
					
			else if @request.params.phase and not @request.context.phase
				debug 'context', 'setting phase'
				unless @request.context.project then return failure error.server "attempt to set phase context with no project set"
				_.extend @request.context, {
					phase:_.find(@request.context.project.phases, (phase)=>if String(phase.id) is String(@request.params.phase) then true else false)
				}
				unless @request.context.phase then return failure error.notFound() # phase not in project
				return checkNext()
	
			else if (p = @request.params.file or @request.params.attachment) and not @request.context.attachment
				debug 'context', 'setting attachment'
				db.attachments.get {project:@request.context.project._id, _id:p}, (err, attachment) =>
					if err? then return failure err
					unless attachment then return failure error.notFound()
					_.extend @request.context, {attachment}
					return checkNext()
					
			else if @request.params.workspace and not @request.context.workspace
				debug 'context', 'setting workspace'
				db.workspaces.getById @request.params.workspace, (err, workspace) =>
					debug 'context', 'found sub', workspace
					if err? then return failure err
					unless workspace then return failure error.notFound()
					_.extend @request.context, {workspace}
					return checkNext()
			
			else
				debug 'context', 'setContext finished', {context:@request.context}
				success()
		
		debug 'context', 'setting context'
		checkNext()
