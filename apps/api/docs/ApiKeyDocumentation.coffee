Documentation = require './framework/Documentation'

class ApiKeyDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'API Key'
		@desc = 'Represents an API key which can be used to send requests to AgileZen'
		@kind = 'object'
	
		@property
			name: 'id'
			type: 'uuid'
			desc: "The key's identifier"
		
		@property
			name: 'name'
			type: 'string'
			desc: 'A descriptive name for the key'
			
		@property
			name: 'enabled'
			type: 'boolean'
			desc: 'Whether the key is allowed to send requests'
		
		@property
			name: 'created'
			type: 'date'
			desc: 'The time the key was created'
		
		@property
			name: 'updated'
			type: 'date'
			desc: 'The time the key was updated'

module.exports = ApiKeyDocumentation
