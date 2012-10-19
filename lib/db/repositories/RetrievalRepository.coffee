DocumentRepository = require './framework/DocumentRepository'
Retrieval = require '../models/Retrieval'

db = require 'lib/db'
uuid = require 'lib/uuid'

module.exports = new class RetrievalRepository extends DocumentRepository

	_model: Retrieval
	
	create: (user, callback) ->
		
		retrieval = new Retrieval
			_id:         uuid.generate()
			user:        user
				
		@save retrieval, callback
		

