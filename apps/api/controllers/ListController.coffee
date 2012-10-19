Controller = require './framework/Controller'
PageResult = require 'lib/results/framework/PageResult'
UserResult = require 'lib/results/UserResult'

db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'

module.exports = class ListController extends Controller

	get:
		before: ['setContext', 'ensureIsAuthenticated']
		handler: (success, failure) ->

	list:
		before: ['setContext', 'ensureIsAuthenticated']
		handler: (success, failure) ->

	update:
		before: ['setContext', 'ensureIsListOwner']
		handler: (success, failure) ->
