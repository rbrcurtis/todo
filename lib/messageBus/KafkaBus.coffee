kafka = require 'kafka'


module.exports = class KafkaBus
	
	constructor: ->
		@_consumerHandlers = {} #topic = [handlers]
		@_consumerReadyQueue = []
		
		@_consumerReady = false
		@_consumerConnectCalled = false

		@_producers = {} #topic = producer

	
	subscribe: (topic, partition, options, handler) ->
		@_onConsumerReady =>
			unless @_consumerHandlers[topic]?
				@_consumerHandlers[topic] = []
				@_consumer.subscribeTopic {name:topic, partition}
				offsets = @_consumer.fetchOffsets(topic)
				debug 'kafka', {offsets}
				@_consumer.once 'lastmessage', (topic, offset) =>
					debug 'kafka', 'lastmessage', topic, offset
					@_consumerHandlers[topic].push handler
			else @_consumerHandlers[topic].push handler
		

	publish: (topic, partition, message) ->
		debug 'kafka', 'publish', topic, message
		@_connectProducer topic, partition, (producer) =>
			try 
				message = JSON.stringify message
			catch e
				debug 'kafka', 'message not json', message
			producer.send message

	_connectConsumer: ->
		debug 'kafka', 'connecting consumer to', CONFIG.kafka.host
		@_consumer = new kafka.Consumer({
			host:         CONFIG.kafka.host
			port:         CONFIG.kafka.port
			pollInterval: CONFIG.kafka.pollInterval
			maxSize:      CONFIG.kafka.maxSize
		})
		@_consumer.connect (err) =>
			debug 'kafka', 'connect cb', arguments
			if err?
				logError err
				return setTimeout (=>@_connectConsumer()), 5000
			
			@_consumer.on 'message', @_onMessage
			@_ready = true
			callback() while callback = @_consumerReadyQueue.shift()
	
	_connectProducer: (topic, partition, callback) ->
		if @_producers[topic] then return callback @_producers[topic]
		@_producers[topic] = new kafka.Producer({
			host:   CONFIG.kafka.host
			port:   CONFIG.kafka.port
			topic
			partition
		})
		debug 'kafka', 'connecting producer to', CONFIG.kafka.host
		@_producers[topic].connect (err) =>
			debug 'kafka', 'producer', topic, 'connect callback', arguments
			if err then return logError 'dropped publish message on topic', topic, 'because connect error', err
			callback @_producers[topic]
			
	_onMessage: (topic, message) =>
		if (handlers = @_consumerHandlers[topic]).length
			try
				message = JSON.parse message
			catch e
				debug 'kafka', 'message not json', message
			handler(message) for handler in handlers
				
				
	_onConsumerReady: (callback) ->
		unless @_connectConsumerCalled then @_connectConsumer()
		if @_consumerReady then return callback()
		@_consumerReadyQueue.push callback
		
		