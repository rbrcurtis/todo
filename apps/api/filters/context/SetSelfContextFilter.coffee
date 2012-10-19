Filter = require '../framework/Filter'

class SetSelfContextFilter extends Filter
	
	before: (success, failure) ->
		if @user? then @request.context = {user: @user}
		success()

module.exports = SetSelfContextFilter
