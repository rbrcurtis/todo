db = require 'lib/db'

projects = {}
missing = 0

getProject = (projectId, cb) ->
	if projects[projectId]? then return cb null, projects[projectId]
	db.projects.get {_id:projectId}, (err, project) ->
		if err then return cb err
		# debug 'activity', 
		unless project then return cb "project not found #{missing++}"
		projects[projectId] = project
		return cb null, project
		

db.activities.find(documentType:'Card',_id:'4ffdace922040240b59100a6').each (err,activity) ->
	unless activity?
		console.log 'done'
		return
		# process.exit(0)

	console.log activity._id
	
	# return
	
	getProject activity.project, (err, project) ->
		
		metastisize = (phases, phaseId) ->
			console.log 'fluffing', phaseId
			for phase, pos in phases
				if String(phase.id) is String(phaseId)
					phase = phase.toJSON()
					phase.index = pos
					activity.meta ?= {}
					activity.meta.Phase ?= {}
					activity.meta.Phase[phaseId] = phase
					console.log 'fluffed', phaseId
					return
			return {name: 'unknown',type: 'unknown', index:-1}
		try
			unless project then return logError 'missing project', activity.project
			metastisize project.phases, activity.document.phase
			
			if activity.previous?.phase
				console.log 'fluffing previous'
				metastisize project.phases, activity.previous.phase
				
			console.log 'phase length', Object.keys(activity.meta.Phase).length
			
			unless activity.shardKey then activity.shardKey = 'foo'
			
			activity.markModified 'meta'
			
			activity.save()
			console.log activity.meta
			
		catch e
			logError e, activity
			
