module.exports = (req, res, next) ->
	res.clearCookie CONFIG.cookies.auth.name, {domain: CONFIG.cookies.auth.domain}
	res.redirect "https://beta.agilezen.com/logged-out"
