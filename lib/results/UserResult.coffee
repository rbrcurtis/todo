avatar = require 'lib/avatar'
DocumentResult = require './framework/DocumentResult'

module.exports = class UserResult extends DocumentResult
	
	constructor: (user) ->
		super

		@name     = user.name
		@username = user.username
		@avatar   = user.avatar or avatar.url(user)

