AccessFilter = require './AccessFilter'

class EnsureCanWriteFilter extends AccessFilter
	
	constructor: ->
		super
		@requiredAccess = 'write'

module.exports = EnsureCanWriteFilter
