
DocumentRepository = require './framework/DocumentRepository'
List = require '../models/List'

uuid = require 'lib/uuid'
db = require 'lib/db'

UserResult = require 'lib/results/UserResult'

ObjectId = require('mongodb').ObjectID

module.exports = new class ListRepository extends DocumentRepository

	_model: List