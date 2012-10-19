bcrypt = require 'bcrypt'
crypto = require 'crypto'

module.exports = new class AuthService
	
	hashPassword: (plaintext) ->
		salt = bcrypt.genSaltSync(10)
		pass = bcrypt.hashSync(plaintext, salt)
		return pass
		
	verifyPassword: (plaintext, hash) ->
		authed = bcrypt.compareSync plaintext, hash
		
	hashPasswordOld: (plaintext) ->
		hash = crypto.createHash 'sha256'
		hash.update(plaintext, 'utf8')
		return hash.digest('hex')
		
	verifyPasswordOld: (plaintext, hash) ->
		@hashPasswordOld(plaintext) is hash
		
