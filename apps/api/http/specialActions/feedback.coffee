auth = require 'lib/auth'
db = require 'lib/db'
error = require 'lib/error'
uuid = require 'lib/uuid'

multipass = new (require 'multipass')(CONFIG.uservoice.apikey, CONFIG.uservoice.sitekey)


module.exports = (req, res, next) ->
	
	debug 'multipass', 'mp user', req.request.user
	user = req.request.user
	
	unless user? then return res.redirect "http://betafeedback.agilezen.com"
	
	expires = new Date()
	expires.setTime(expires.getTime()+1000*60*5)
	token = multipass.encode
		guid: String(user._id)
		display_name: user.name
		login: user.username
		email: user.email
		
	url = "http://betafeedback.agilezen.com?sso=#{token}"
	debug 'feedback', 'token', token
	res.redirect url
