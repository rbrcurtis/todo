Filter = require './framework/Filter'

db = require 'lib/db'
error = require 'lib/error'

class EnsureIsAccessingSelfFilter extends Filter
	
	before: (success, failure) ->
		unless @user?
			return failure error.unauthorized()

		unless String(@user._id) is String(@request.params.user)
			return failure error.forbidden()
			
		return success()
	
module.exports = EnsureIsAccessingSelfFilter
