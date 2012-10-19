
describe 'Workspace', ->
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
			assert.equal err, null

			for cookie in response.headers['set-cookie']
				testLog cookie
			jsid = response.headers['set-cookie'][1]
			jsid = jsid.substring(jsid.indexOf('=')+1, jsid.indexOf(';'))
			testLog 'jsid', jsid

			url =  "https://test1cluster1.rallydev.com"
			request.get url, (err, response, body) ->
				testLog 'get', response.statusCode, body?.length

				done()

	it 'get by id', (done) ->
		db.workspaces.getById '5222494897', {jsid}, (err, workspace) ->
			assert.equal err, null
			assert.equal workspace.name, "2012 Worldwide Sales Kickoff"

			done()

	it 'find by owner', (done) ->
		db.users.getById '79264751', {jsid}, (err, owner) ->
			assert.equal err, null

			db.workspaces.findByOwner owner, {jsid}, (err, workspaces) ->
				assert.equal err, null

				testLog 'workspace', workspaces+""

				assert.ok workspaces.length, 'got results'
				assert.equal workspaces[0].name, "2012 Worldwide Sales Kickoff"

				done()


	it 'gets multiple by id', (done) ->
		db.workspaces.findByIdList ['44905727', '41529001'], {jsid}, (err, workspaces) ->
			assert.equal err, null

			testLog '2 workspaces', workspaces+""

			assert.ok workspaces.length is 2, 'got results'

			done()


