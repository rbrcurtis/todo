Documentation = require './framework/Documentation'

class MeDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Me'
		@desc = 'Represents the currently logged-in user (you!)'
		@kind = 'object'
		
		@property
			name: 'id'
			type: 'uuid'
			desc: 'Your identifier'
		
		@property
			name: 'name'
			type: 'string'
			desc: 'Your name'
			
		@property
			name: 'email'
			type: 'string'
			desc: 'Your email address'
		
		@property
			name: 'avatar'
			type: 'string'
			desc: 'The URL of your avatar'
		
		@property
			name: 'created'
			type: 'date'
			desc: 'The time you created your account'
		
		@property
			name: 'updated'
			type: 'date'
			desc: 'The time your information was last changed'
		
		@property
			name: 'apiKeys'
			type: 'array'
			desc: 'Your API keys'
			formatters:
				'id': @link '/me/apikeys/:value'
				
		@property
			name: 'projects'
			type: 'array'
			desc: 'Projects of which you are a member'
			comma: false
			formatters:
				'phases.id':     @link '/phases/:value'
				'roles.id':      @link '/projects/:parent.id/roles/:value'
				'roles.members': @link '/users/:value'
				'workspace':  @link '/workspaces/:value'
				'members':       @link '/users/:value'
				'id':            @link '/projects/:value'

module.exports = MeDocumentation
