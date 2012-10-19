HttpRequest = require '../HttpRequest'

module.exports = () ->
	return (req, res, next) ->
		req.request = new HttpRequest(req.route, req)
		next()