Documentation = require './framework/Documentation'

class StoryOwnerDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Story Owner'
		@desc = 'Represents a user who is working on a card'
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

module.exports = ProjectMemberDocumentation
