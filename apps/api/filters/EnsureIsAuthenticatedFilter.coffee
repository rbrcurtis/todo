Filter = require './framework/Filter'
error = require 'lib/error'

class EnsureIsAuthenticatedFilter extends Filter
	
	before: (success, failure) ->
		debug 'auth', 'authing', @user
		unless @user?
			return failure error.unauthorized()
		return success()
	
module.exports = EnsureIsAuthenticatedFilter
