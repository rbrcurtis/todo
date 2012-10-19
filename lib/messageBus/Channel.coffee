class Channel
	
	constructor: (@messageBus, @exchangeName, @queueName, @options) ->
	
	subscribe: (handler) ->
		@messageBus.subscribe(@exchangeName, @queueName, @options, handler)
	
	publish: (message) ->
		if message.toJSON
			debug 'queue', 'toJSON'
			message = JSON.parse JSON.stringify message
		debug 'queue', 'sending', @exchangeName, message
		@messageBus.publish(@exchangeName, @queueName, message)

module.exports = Channel
