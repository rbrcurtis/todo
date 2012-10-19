AccessFilter = require './AccessFilter'

module.exports = class EnsureCanReadFilter extends AccessFilter
	
	constructor: ->
		super
		@requiredAccess = 'read'

	before: (success, failure) ->
		args = arguments
		@getProjectForRequest (err, project) =>
			if err?         then return failure err
			if not project? then return failure error.notFound()

			if project.public is true
				debug 'public', 'public board'
				return success()
			
			EnsureCanReadFilter.__super__.before.apply(this, args)

