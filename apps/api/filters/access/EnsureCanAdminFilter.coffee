AccessFilter = require './AccessFilter'

module.exports = class EnsureCanAdminFilter extends AccessFilter
	
	constructor: ->
		super
		@requiredAccess = 'admin'

