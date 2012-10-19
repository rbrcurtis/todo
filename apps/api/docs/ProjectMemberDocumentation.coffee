Documentation = require './framework/Documentation'

class ProjectMemberDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Project Member'
		@desc = 'Represents a user who is a member of a project'
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
