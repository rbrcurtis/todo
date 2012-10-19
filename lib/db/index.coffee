exports.mongoose = mongoose = require 'mongoose'
{Server} = require 'mongodb'

log "[MONGOOSE] connecting to #{CONFIG.mongo.url}"

onError = (error) => if error then logError "[MONGOOSE] error #{error}"

connect = ->
	if CONFIG.mongo.url.split(',').length>=2
		mongoose.connectSet CONFIG.mongo.url, null, {replset:{readPreference: Server.READ_SECONDARY}}, onError
	else
		mongoose.connect CONFIG.mongo.url, onError
		
connect()
	
mongoose.connection.on 'open', => log "[MONGOOSE] connection established to #{CONFIG.mongo.url}"
mongoose.connection.on 'close', => logError "[MONGOOSE] close"
mongoose.connection.db.on 'error', => logError 'connection error', arguments...
mongoose.connection.on 'disconnect', => logError "[MONGOOSE] disconnect"

# Real documents
exports.users         = require './repositories/UserRepository'
exports.lists         = require './repositories/ListRepository'

# Embedded documents
exports.items         = require './repositories/ItemRepository'
