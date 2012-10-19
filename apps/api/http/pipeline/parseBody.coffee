crypto = require 'crypto'
formatting = require '../../formatting'
error = require 'lib/error'

module.exports = () ->
	return (req, res, next) ->
		# Skip GETs and DELETEs, since they don't have a body.
		if req.method == 'GET' or req.method == 'DELETE'
			return next()
		
		req.formatter.deserialize req, (err) ->
			if err? then return next err
			next()
