Role = require 'lib/db/rally/models/Role'
describe 'Project', ->
	CONFIG.db.impl = 'rally'
	
	request = require 'request'
	db = require 'lib/db'

	jsid = null
	username = 'rcurtis@rallydev.com'
	password = 'qwer1234'

	it 'setup', (done) ->

		url = "https://test1cluster1.rallydev.com/slm/j_spring_security_check"
		testLog "url", url

		request.post url, {form: {j_username:username,j_password:password}}, (err, response, body) ->
			for cookie in response.headers['set-cookie']
				testLog cookie
			jsid = response.headers['set-cookie'][1]
			jsid = jsid.substring(jsid.indexOf('=')+1, jsid.indexOf(';'))
			testLog 'jsid', jsid

			url =  "https://test1cluster1.rallydev.com"
			request.get url, (err, response, body) ->
				testLog 'get', response.statusCode, body?.length

				done()

	it 'gets by id', (done) ->
		db.projects.getById '5222494981', {jsid}, (err, project) =>
			assert.equal err, null
			testLog 'getById', err, project
			assert project.roles[0] instanceof Role

			done()
