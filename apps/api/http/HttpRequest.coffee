Request = require '../common/Request'

class HttpRequest extends Request
	
	constructor: (route, httpRequest) ->
		super
		@transport = 'http'
		@async = httpRequest.header(CONFIG.http.headers.async) is 'true'
		@client = httpRequest.header(CONFIG.http.headers.client)
		@clientReqId = httpRequest.header('X-Client-Request-Id')
		
		@controller = route.controller
		@action = route.action
		@http =
			address: httpRequest.header('x-forwarded-for') ? httpRequest.connection.remoteAddress
			pattern: route.pattern
			url: httpRequest.url
			verb: httpRequest.method
			headers: _.clone httpRequest.headers
			cookies: _.clone httpRequest.cookies
		
		for hash in ['params', 'query', 'body', 'files', 'fields']
			for key, value of httpRequest[hash]
				@params[key] = value

module.exports = HttpRequest
