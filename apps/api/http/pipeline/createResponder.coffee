HttpResponder = require '../HttpResponder'
AsyncResponder = require '../../common/AsyncResponder'

module.exports = () ->
	return (req, res, next) ->
		request = req.request
		if request.async
			req.responder = new AsyncResponder(request)
		else
			req.responder = new HttpResponder(request, req, res)
		next()
