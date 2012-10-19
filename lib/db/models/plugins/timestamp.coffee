module.exports = (schema) ->
	schema.add
		created: {type: Date, mutable: false, trackChanges: false}
		updated: {type: Date, mutable: false, trackChanges: false}
	schema.pre 'save', (next) ->
		if @isNew and not @created? then @created = Date.now()
		@updated = Date.now()
		next()
