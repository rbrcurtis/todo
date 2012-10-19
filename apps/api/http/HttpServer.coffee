fs = require 'fs'
events = require 'events'
express = require 'express'

auth = require 'lib/auth'
error = require 'lib/error'
uuid = require 'lib/uuid'

routes = require '../routes'
controllers = require '../controllers'
pipeline = require './pipeline'
specialActions = require './specialActions'

module.exports = class HttpServer extends events.EventEmitter

	constructor: ->
		@app = express.createServer()
		
		@pipeline = [
			express.cookieParser()
			pipeline.createRequestObject()
			pipeline.createResponder()
			pipeline.createFormatters()
			pipeline.setDefaultHeaders()
			pipeline.parseBody()
			pipeline.logRequest()
			pipeline.authenticate()
			pipeline.throttle()
		]
		
		# this is used for errors that occure outside of the controller
		@app.error (err, req, res, next) ->
			if req.responder?
				if err instanceof error.RequestError
					req.responder.failure(err)
				else
					req.responder.failure error.server err
			else
				next(err)
		
		@_loadRoutes()
		
		loginPipeline = [pipeline.logRequest(), express.cookieParser(), express.bodyParser(), pipeline.setDefaultHeaders()]
		supportPipeline = [pipeline.logRequest(), express.cookieParser(), pipeline.createRequestObject(), pipeline.authenticate()]
		
		@app.get     '/', (req, res) -> res.send 'here thar be dragons'
		@app.post    '/login',     loginPipeline, specialActions.login
		@app.get     '/logout',    loginPipeline, specialActions.logout
		@app.post    '/register',  loginPipeline, specialActions.register
		
		@app.options '*',          pipeline.setDefaultHeaders(), (req, res) ->
			res.send 200
		
		@app.error (err, req, res, next) ->
			debug 'error', 'global error handler', err
			if err instanceof error.RequestError
				res.send err.message, err.status
			else next err
		
	start: ->
		@app.listen CONFIG.http.port, =>
			addr = @app.address()
			log "listening on http://#{addr.address}:#{addr.port}"

	_handleRequest: (req, res, next) =>
		# If the request is intended to be asynchronous, close the HTTP connection
		# immediately, before we start processing it.
		if req.request.async then res.send(202)
		
		success = _.bind(req.responder.success, req.responder)
		failure = _.bind(req.responder.failure, req.responder)
		
		@emit('request', req.request, req.user, success, failure)

	_loadRoutes: ->
		for controller, actions of routes
			unless controllers[controller]?
				throw new Error("routes defined for non-existent controller #{controller}")
			for action, pattern of actions
				@_registerRoute(controller, action, pattern)
	
	_registerRoute: (controller, action, pattern) ->
		route = {controller: controller, action: action}
		[route.verb, route.pattern] = pattern.split(/\s+/, 2)
		attachRoute = (req, res, next) ->
			req.route = route
			next()
		@app[route.verb] route.pattern, attachRoute, @pipeline, @_handleRequest

