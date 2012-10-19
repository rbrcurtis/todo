class Formatter

	constructor: ->
		throw new Error("You must specify which media types are understood in #{@constructor.name}") unless @understands?
		throw new Error("You must specify which media type is generated in #{@constructor.name}") unless @generates?
	
	serialize: (obj, callback) ->
		throw new Error("You must override serialize() in #{@constructor.name}")
		
	aggregate: (req, callback) ->
		
		expectedHash = req.header('content-md5')
		expectedLength = parseInt req.header('content-length')
		if _.isNaN(expectedLength) then expectedLength = undefined
		
		if expectedHash?
			hash = crypto.createHash('md5')
		
		data = ''
		req.setEncoding('utf8')
		
		req.on 'data', (chunk) ->
			data += chunk
			hash.update(chunk) if hash?
			
		req.on 'end', ->
			if expectedLength? and Buffer.byteLength(data) != expectedLength
				return next error.badLength()
			if hash? and hash.digest('base64') != expectedHash
				return next error.badDigest()
			
			callback(data)
	
	deserialize: (req, callback) ->
		throw new Error("You must override deserialize() in #{@constructor.name}")

module.exports = Formatter
