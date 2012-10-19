formatting = require '../../formatting'
error = require 'lib/error'

parseContentType = (header) ->
	if not header? or header.length == 0
		return formatting.DEFAULT_MEDIA_TYPE
	index = header.indexOf(';')
	if index is -1 then header else header.substr(0, index)

# Returns an array of options from the Accept header ordered by quality if it's specified.
# (Based on express.js by TJ Holowaychuk)
parseAccept = (header) ->
	if not header? or header.length == 0 or header == '*/*'
		return [formatting.DEFAULT_MEDIA_TYPE]
	
	formats = []
	for option in header.split /\s*,\s*/
		[format, quality] = option.split /\s*;\s*/
		quality = if quality? then parseFloat quality.split(/\s*=\s*/)[1] else 1
		formats.push {format, quality}
	formats.sort (a, b) ->
		b.quality - a.quality
		
	return _.pluck(formats, 'format')

module.exports = () ->
	return (req, res, next) ->
		request = req.request
		
		inputFormat   = parseContentType req.header('content-type')
		outputFormats = parseAccept req.header('accept')
		
		req.formatter = formatting.getFormatter(inputFormat)
		unless req.formatter?
			return next error.unsupportedMedia()

		res.formatter = formatting.getFormatter(outputFormats)
		unless res.formatter?
			return next error.notAcceptable()
		
		request.format =
			input:  req.formatter.generates
			output: res.formatter.generates
		
		next()
