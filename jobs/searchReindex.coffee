db = require 'lib/db'
search = require 'lib/search'

db.cards.find().each (err,card, next) ->
	unless card? then return log "done with cards"
	if err then return next()
	search.save 'Card', card, (err) -> next()

db.attachments.find().each (err,attachment, next) ->
	unless attachment? then return log "done with attachments"
	if err then return next()
	search.save 'Attachment', attachment, (err) -> next()