controllers = require '../controllers'
filters = require '../filters'
error = require 'lib/error'

arrayify = (value) ->
	return if _.isArray(value) then value else [value]

class Dispatcher
	
	dispatch: (request, user, success, failure) ->
		controller = @_createController(request.controller, request, user)
		spec = controller[request.action]
		
		unless spec?
			throw new Error("don't know how to dispatch request for action #{request.action} on #{request.controller} controller")
		if not spec.handler? or not spec.handler instanceof Function
			throw new Error("invalid action definition for #{request.action} on #{request.controller} controller")
		
		# This callback is executed after the call to the handler succeeds. If any "after" filters are defined,
		# it chains them together, otherwise it just calls the success() callback to return the result to the
		# transport layer.
		afterHandlerSucceeds = (result) =>
			if spec.after?
				@_executeFilterChain arrayify(spec.after), 'after', request, user, result, success, failure
			else
				success(result)
		
		# This callback executes the handler function itself. It's either triggered immediately, or after the
		# "before" chain of filters if any are defined.
		runHandler = ->
			try
				spec.handler.apply controller, [afterHandlerSucceeds, failure]
			catch e
				logError e
				return failure error.server()
		
		if spec.before?
			@_executeFilterChain arrayify(spec.before), 'before', request, user, null, runHandler, failure
		else
			runHandler()

	_createController: (name, request, user) ->
		unless controllers[name]?
			throw new Error("request received for non-existent controller #{request.controller}, what the actual fuck is going on")
		controller = new controllers[name](request, user)
	
	_createFilter: (name, request, user) ->
		unless filters[name]?
			throw new Error("invalid filter #{name} defined for #{request.action} action on #{request.controller} controller")
		return new filters[name](request, user)
	
	_executeFilterChain: (filters, method, request, user, result, success, failure) ->
		queue = filters.slice(0)
		iterate = =>
			next = ->
				if queue.length is 0
					success(result)
				else
					process.nextTick(iterate)
			filterName = queue.shift()
			filter = @_createFilter(filterName, request, user)
			unless filter[method]? and filter[method] instanceof Function
				throw new Error("filter #{filterName} was defined in the #{method} chain for #{request.action} action on #{request.controller} controller, but it has no #{method}() method")
			filter[method].apply filter, [next, failure]
		iterate()	

module.exports = Dispatcher