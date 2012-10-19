Documentation = require './framework/Documentation'

class RoleMemberDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Role Member'
		@desc = 'Represents a user who is a member of a role'
		@kind = 'object'
		
		@property
			name: 'id'
			type: 'uuid'
			desc: "The user's identifier"
		
		@property
			name: 'username'
			type: 'string'
			desc: "The user's username"
		
		@property
			name: 'name'
			type: 'string'
			desc: "The user's name"
			
		@property
			name: 'avatar'
			type: 'string'
			desc: "The URL to the user's avatar"

module.exports = RoleMemberDocumentation
