ALLOW_HEADERS = [
	'Accept'
	'Authorization'
	'Content-Length'
	'Content-MD5'
	'Content-Type'
	'X-Client-Request-Id'
	CONFIG.http.headers.async
	# CONFIG.http.headers.apiKey
	# CONFIG.http.headers.useCookie
].join(', ')
EXPOSE_HEADERS = [
	'X-Request-Id'
	'X-Response-Time'
	'X-RateLimit-Limit'
	'X-RateLimit-Remaining'
].join(', ')

module.exports = () ->
	return (req, res, next) ->
		res.header('X-Powered-By', 'Big Bang')
		if req.request? then res.header(CONFIG.http.headers.requestid, req.request.id)
		
		res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE')
		res.header('Access-Control-Allow-Credentials', 'true')
		
		debug 'auth', 'origin', req.header('Origin')
		
		if req.header('Origin')
			res.header('Access-Control-Allow-Origin', req.header('Origin'))
		else
			res.header('Access-Control-Allow-Origin', '*')
			
		res.header('Access-Control-Allow-Headers', ALLOW_HEADERS)
		res.header('Access-Control-Expose-Headers', EXPOSE_HEADERS)
			
		next()




