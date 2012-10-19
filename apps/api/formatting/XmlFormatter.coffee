# Formatter = require './Formatter'
# parser = require 'xml2json'
# 
# class XmlFormatter extends Formatter
# 
	# understands: ['application/xml', 'text/xml']
	# generates: 'application/xml'
# 	
	# serialize: (request, result, callback) ->
		# try
			# data = parser.toXml(result)
			# callback(null, data)
		# catch err
			# callback(err)
# 	
	# deserialize: (request, callback) ->
		# @aggregate request, (data) ->
			# try
				# request.body = parser.toJson data, {object: true}
				# callback(null, obj)
			# catch err
				# callback(err)
# 
# module.exports = XmlFormatter
