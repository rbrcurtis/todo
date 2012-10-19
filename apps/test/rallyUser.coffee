describe 'User', ->
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

	it 'gets user by token', (done) ->
		db.users.getByToken jsid, null, (err, user) ->
			testLog 'user', err, user.toJSON()

			assert.equal user.username, username

			testLog 'has JSON', user._json

			done()

	it 'gets user by username', (done) ->
		db.users.getByUsername 'rcurtis@rallydev.com', {jsid}, (err, user) ->
			testLog 'user', err, user.toJSON()

			assert.equal user.username, username

			done()
	
	it 'gets user by id', (done) ->
		db.users.getById '7625055242', {jsid}, (err, user) ->
			testLog 'user', err, user.toJSON()

			assert.equal user.username, username

			done()

	it 'gets user by email', (done) ->
		db.users.getByEmail 'rcurtis@rallydev.com', {jsid}, (err, user) ->
			testLog 'user', err, user.toJSON()

			assert.equal user.username, username

			done()

	# TODO
	# it 'gets all project members', (done) ->
		# db.users.findByProject 400060, {jsid}, (err, users) ->

		# 	assert.ok users.length

		# 	done()

	# it 'gets all workspace members', (done) ->
	# 	db.users.getWorkspaceMembers {_id:'44905727'}, {jsid}, (err, users) ->
	# 		assert.equal null, err

	# 		assert.ok users?.length, 'no users returned'

	# 		done()