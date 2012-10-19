JsonFormatter = require './JsonFormatter'
# XmlFormatter = require './XmlFormatter'
HtmlFormatter = require './HtmlFormatter'
FormFormatter = require './FormFormatter'

formatters = [
	new JsonFormatter()
	new HtmlFormatter()
	# new XmlFormatter()
	new FormFormatter()
]

module.exports =
	
	DEFAULT_MEDIA_TYPE: 'application/json'
	
	getFormatter: (mediaTypes) ->
		if not _.isArray(mediaTypes) then mediaTypes = [mediaTypes]
		_.find formatters, (formatter) ->
			_.intersection(formatter.understands, mediaTypes).length > 0
