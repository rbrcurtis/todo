auth = require 'lib/auth'
db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'

multipass = new (require 'multipass')(CONFIG.tender.apikey, CONFIG.tender.sitekey)


module.exports = (req, res, next) ->
	
	debug 'multipass', 'mp user', req.request.user
	user = req.request.user
	
	unless user? then return res.send 401
	
	expires = new Date()
	expires.setTime(expires.getTime()+1000*60*5)
	userobj = 
		name: user.name
		login: user.username
		email: user.email
		unique_id: CONFIG.tender.prefix+String(user._id)
		expires: expires.toString()
	debug 'multipass', 'userobj', userobj
	token = multipass.encode userobj
		
	
	# url = "http://#{CONFIG.tender.sitekey}.tenderapp.com?sso=#{token}"
	url = "http://betahelp.agilezen.com?sso=#{token}"
	debug 'multipass', 'url', url
	res.redirect url
