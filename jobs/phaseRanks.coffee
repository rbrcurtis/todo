db = require 'lib/db'

db.projects.find().each (err, proj) ->
	unless proj
		return console.log 'done'
		
	console.log proj.id
	
	ix = 1000000
	for phase in proj.phases
		phase.rank = ix
		ix += 1000000
	
	proj.save()
