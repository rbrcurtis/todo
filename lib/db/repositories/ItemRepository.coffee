EmbeddedDocumentRepository = require './framework/EmbeddedDocumentRepository'
ItemSchema = require('../models/Item').schema

db = require 'lib/db'
uuid = require 'lib/uuid'

module.exports = new class ItemRepository extends EmbeddedDocumentRepository
	
	setup: ->
		@_schema = ItemSchema
		@parent = 'List'
		@_path   = 'items'

