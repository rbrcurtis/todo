HttpRequest = require '../HttpRequest'
HttpResponder = require '../HttpResponder'
AsyncResponder = require '../../common/AsyncResponder'

db = require 'lib/db'
error = require 'lib/error'

module.exports = () ->
	return (req, res, next) ->
		
		


		if req.request.params?.apikey
			apikey = req.request.params.apikey
			if apikey.length isnt 24
				return next("invalid apikey")
			[scheme, value] = ['apikey', req.request.params.apikey]
		else
			header = req.header('authorization')
			if not header? then scheme = 'cookie'
			else [scheme, value] = header.split(' ', 2)
		
		done = (err, user) ->
			if err? then return next(err)
			if user?
				req.user = user
				req.request.user = user
				user.accessed = new Date()
				user.save()
			next()
			
		debug 'auth', 'auth', scheme, req.cookies
		
		switch scheme.toLowerCase()
			when 'cookie'
				token = req.cookies[CONFIG.cookies.auth.name]
				if not token? then return next()
				req.request.auth = {method: 'cookie', value: token}
				return db.users.getByToken token, done
			when 'apikey'
				apiKey = value.trim()
				if not apiKey? then return next()
				log "apikey", {method: 'apiKey', value: value}
				req.request.auth = {method: 'apiKey', value: value}
				return db.users.getByApiKey value, done
			else
				next error.unauthorized()
