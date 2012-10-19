Documentation = require './framework/Documentation'

class RoleDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Role'
		@desc = 'Represents a group of like users collaborating on a project'
		@kind = 'object'
	
		@property
			name: 'id'
			type: 'uuid'
			desc: "The role's identifier"
		
		@property
			name: 'name'
			type: 'string'
			desc: 'A descriptive name for the role'
			
		@property
			name: 'created'
			type: 'date'
			desc: 'The time the role was created'
		
		@property
			name: 'updated'
			type: 'date'
			desc: 'The time the role was updated'
		
		@property
			name: 'access'
			type: 'string'
			desc: 'The maximum access level (read, write, or admin) of actions that the members of the role can perform'
		
		@property
			name: 'members'
			type: 'array'
			desc: 'The IDs of the users who are members of the role'
			formatter: @link '/users/:value'

module.exports = RoleDocumentation
