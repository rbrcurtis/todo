Filter = require '../framework/Filter'

db = require 'lib/db'
error = require 'lib/error'

module.exports = class EnsureIsSiteAdminFilter extends Filter
	
	
	before: (success, failure) ->
		if not @user? then return failure error.unauthorized()
		if @user.siteAdmin
				return success()
			else
				return failure error.forbidden()
	

