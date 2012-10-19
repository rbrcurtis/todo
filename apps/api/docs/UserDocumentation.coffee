Documentation = require './framework/Documentation'

class UserDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'User'
		@desc = 'Represents a user of AgileZen'
		@kind = 'object'
		
		@property
			name: 'id'
			type: 'uuid'
			desc: "The user's identifier"
		
		@property
			name: 'name'
			type: 'string'
			desc: "The user's name"
			
		@property
			name: 'email'
			type: 'string'
			desc: "The user's email address"
		
		@property
			name: 'created'
			type: 'date'
			desc: "The time the user's account was created"
		
		@property
			name: 'updated'
			type: 'date'
			desc: "The time the user's information was last changed"

module.exports = UserDocumentation
