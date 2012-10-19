Formatter = require './Formatter'
formidable = require 'formidable'
	
module.exports = class FormFormatter extends Formatter

	understands: ['multipart/form-data','application/x-www-form-urlencoded']
	generates: 'application/json'
	
	serialize: (request, result, callback) ->
		try
			data = JSON.stringify(result)
			callback(null, data)
		catch err
			callback(err)
	
	deserialize: (request, callback) ->
		try
			form = new formidable.IncomingForm()
			form.uploadDir = CONFIG.files.uploadDir
			form.parse request, (err, body, files) =>
				log 'form', {err, body, files}
				request.request.body  = body
				request.request.files = files
				callback(request.request.fields)
		catch err
			callback(err)

