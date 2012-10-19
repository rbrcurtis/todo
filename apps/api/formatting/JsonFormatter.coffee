Formatter = require './Formatter'

error = require 'lib/error'

module.exports = class JsonFormatter extends Formatter

	understands: ['application/json', 'text/javascript']
	generates: 'application/json'
	
	serialize: (request, result, callback) ->
		try
			data = JSON.stringify(result, ((key,val)->if val is null then return undefined else return val))
			callback(null, data)
		catch err
			callback(err)
	
	deserialize: (req, callback) ->
		@aggregate req, (data) =>
			try
				debug 'formatter', 'data', data
				unless data then return callback()
				req.request.body = JSON.parse(data)
				callback(null)
			catch err
				logError 'json formatter caught an error', err
				callback(error.badRequest())

