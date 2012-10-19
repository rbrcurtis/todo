Responder = require './Responder'

class AsyncResponder extends Responder
	
	success: (result) ->
		super(result)
	
	failure: (err) ->
		super(err)

module.exports = AsyncResponder