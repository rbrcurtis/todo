config = require './default'

try
	user = require './user'
	for key, val of user
		if typeof val is 'object' and config[key]? then _.extend config[key], val
		else config[key] = val
		
catch ex

module.exports = config
