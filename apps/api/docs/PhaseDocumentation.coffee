Documentation = require './framework/Documentation'

class PhaseDocumentation extends Documentation
	
	constructor: ->
		super
		
		@name = 'Phase'
		@desc = "Represents one step in a project's workflow"
		@kind = 'object'
	
		@property
			name: 'id'
			type: 'uuid'
			desc: "The phase's identifier"
		
		@property
			name: 'name'
			type: 'string'
			desc: 'A descriptive name for the phase'
		
		@property
			name: 'type'
			type: 'string'
			desc: 'The type of work (planning, working, or archive) being done when a card is in the phase'
			
		@property
			name: 'limit'
			type: 'number'
			desc: 'The maximum number of allowable cards in the phase'
		
		@property
			name: 'created'
			type: 'date'
			desc: 'The time the phase was created'
		
		@property
			name: 'updated'
			type: 'date'
			desc: 'The time the phase was updated'

module.exports = PhaseDocumentation
