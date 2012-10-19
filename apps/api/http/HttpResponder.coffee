Responder = require '../common/Responder'
{Stream}  = require 'stream'

error = require 'lib/error'
formatting = require '../formatting'

META_HEADERS =
	lastModified: 'Last-Modified'
	page:         'X-Page'
	pageSize:     'X-Page-Size'
	pageCount:    'X-Page-Count'

module.exports = class HttpResponder extends Responder
	
	constructor: (request, @httpRequest, @httpResponse) ->
		super(request)
	
	success: (result = null) ->
		super
		if not result?
			@_setHeaders()
			@httpResponse.send(204)
		
		else if result instanceof Stream
			filename = @request.file.filename
			type     = @request.file.type
			@httpResponse.header('Content-Type', type)
			if @request.file.download then @httpResponse.header("Content-Disposition", "inline; filename=\"#{filename}\"")
			result.pipe @httpResponse
			
		else if result instanceof Buffer
			filename = @request.file.filename
			type     = @request.file.type
			@httpResponse.header('Content-Type', type)
			if @request.file.download then @httpResponse.header("Content-Disposition", "inline; filename=\"#{filename}\"")
			@httpResponse.send result
			
		else
			@_setHeaders(result.meta)
			@httpResponse.formatter.serialize @request, result, (err, data) =>
				if err?
					if err instanceof error.RequestError
						@httpResponse.send(err.message, err.status)
					else
						@httpResponse.send(err.message ? err, 500)
					return
				@httpResponse.header('Content-Type', @httpResponse.formatter.generates)
				
				@httpResponse.send(data)
				
	
	failure: (err) ->
		debug 'requests', 'request error', err?.name, err
		if err instanceof error.RequestError
			# do nothing! leave it alone!
		else if err instanceof Error
			switch err.name
				when 'ValidationError'
					err = error.badRequest "#{err.errors.text.path} #{err.errors.text.type}"
				when 'MongoError'
					if err.err.match /duplicate/
						err = error.badRequest "the specified value is already in use and must be unique."
					else
						logError 'not sure how to handle response for', err
						log 'request error', err
						err = error.badRequest "#{err.err}"
				else
					logError err
					err = error.server()
		else
			err = error.badRequest(err)
			
		super(err)
		@_setHeaders()
		@httpResponse.send(err.message, err.status)
	
	_setHeaders: (meta) ->
		@httpResponse.header CONFIG.http.headers.duration, @request.duration
		debug 'requests', 'response-time', @request.duration
		if meta?
			for name, value of meta
				header = META_HEADERS[name]
				if header? then @httpResponse.header(header, value)

