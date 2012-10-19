crypto = require 'crypto'

increment = 0

exports.generate = ->
	seconds = Math.round(new Date().getTime() / 1000.0)
	
	buffer = new Buffer(12)
	buffer.writeUInt32BE(seconds, 0)
	buffer.writeUInt16BE(++increment, 10)
	crypto.randomBytes(6).copy(buffer, 4)
		
	return buffer.toString('hex')
