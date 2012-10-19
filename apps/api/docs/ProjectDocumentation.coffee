Documentation = require './framework/Documentation'

class ProjectDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Project'
		@desc = 'Represents a workflow, a team, and a collection of work items.'
		@kind = 'object'
		
		@property
			name: 'id'
			type: 'uuid'
			desc: "The project's unique ID"
		
		@property
			name: 'name'
			type: 'string'
			desc: 'Your name'
		
		@property
			name: 'created'
			type: 'date'
			desc: 'The time the project was created'
		
		@property
			name: 'updated'
			type: 'date'
			desc: 'The time the project was last updated'
			
		@property
			name: 'workspace'
			type: 'uuid'
			desc: 'The ID of the workspace in which the project was created'
			formatter: @link '/workspaces/:value'
		
		@property
			name: 'owners'
			type: 'array'
			desc: 'The IDs of users who are owners of the project'
			formatter: @link '/users/:value'
		
		@property
			name: 'members'
			type: 'array'
			desc: 'The IDs of users who are members of the project'
			formatter: @link '/users/:value'
			
		@property
			name: 'phases'
			type: 'array'
			desc: "The phases that make up the project's workflow"
			formatters:
				'id': @link '/phases/:value'
		
		@property
			name: 'roles'
			type: 'array'
			desc: "The roles defined in the project"
			formatters:
				'id':      @link '/projects/:parent.id/roles/:value'
				'members': @link '/users/:value'

module.exports = ProjectDocumentation
