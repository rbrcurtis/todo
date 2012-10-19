module.exports =
	app:
		url: 'https://todo.agilezen.com'
	http:
		port: 4000
		headers:
			client:        'X-Client'
			async:         'X-Request-Async'
			requestid:     'X-Request-Id'
			duration:      'X-Response-Time'
			rateLimit:     'X-RateLimit-Limit'
			rateLimitRemaining: 'X-RateLimit-Remaining'
	cookies:
		auth:
			name: 'todo.t'
			lifetime: 1000 * 60 * 60 * 24 * 14
			domain: 'todo.agilezen.com'
	mongo:
		url: 'mongodb://localhost/todo'
	redis:
		host: 'localhost'
	rabbit:
		host: 'localhost'
	realtime:
		port: 4100
		countInterval: 2
		allowAnon: true
	rateLimit:
		requestsPerSecond: 1
		burst: 10
	email:
		fromAddress: 'TODO <noreply@agilezen.com>'
	aws:
		keyId:     ''
		key:       ''
