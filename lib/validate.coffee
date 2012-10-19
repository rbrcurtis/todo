module.exports = new class Validator
	
	email: (email) ->
		unless email.match /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i then return "Your email address is not valid."
		return true
	
	username: (username) ->
		unless username.match /[a-z0-9]{3,50}$/i then return "Your username needs to be at least 3 characters and made up only of numbers and letters"
		return true
		
	display: (display) ->
		unless display.match /[a-z0-9 ]{3,50}$/i then return "Your display needs to be at least 3 characters and made up only of numbers, letters and spaces."
		return true
		
	password: (password) ->
		unless password?.length>=5 then return "Your password must be at least 5 characters."
		return true
