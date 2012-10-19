module.exports =
	name: 'api'
	cluster: true
	run: ->
		HttpServer = require './http/HttpServer'
		Dispatcher = require './common/Dispatcher'
	
		server = new HttpServer()
		dispatcher = new Dispatcher()
		server.on 'request', _.bind(dispatcher.dispatch, dispatcher)
	
		server.start()
