Formatter = require './Formatter'
docs = require '../docs'

class HtmlFormatter extends Formatter

	understands: ['text/html']
	generates: 'text/html'
	
	serialize: (request, result, callback) ->
		try
			callback null, docs.render(result)
		catch err
			callback(err)

module.exports = HtmlFormatter
