
module.exports = () ->
	return (req, res, next) ->
		debug 'requests', req.method, 'request to', req.path, (req.request?.body or ''), true
		next()
