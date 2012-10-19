Documentation = require './framework/Documentation'

class WorkspaceDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Workspace'
		@desc = 'Represents a workspace. This is the most useful documentation ever.'
		@kind = 'object'
	
		@property
			name: 'id'
			type: 'uuid'
			desc: "The workspace's identifier"
		
		@property
			name: 'name'
			type: 'string'
			desc: 'A descriptive name for the workspace'
			
		@property
			name: 'created'
			type: 'date'
			desc: 'The time the workspace was created'
		
		@property
			name: 'updated'
			type: 'date'
			desc: 'The time the workspace was updated'
		
		@property
			name: 'owners'
			type: 'array'
			desc: 'The IDs of the users who own the workspace'
			formatter: @link '/owners/:value'

module.exports = WorkspaceDocumentation
