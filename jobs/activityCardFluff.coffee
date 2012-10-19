db = require 'lib/db'

cards = {}
missing = 0

getCard = (projectId, cardId, cb) ->
	if cards[cardId]? then return cb null, cards[cardId]
	db.cards.get {project:projectId, _id:cardId}, (err, card) ->
		if err then return cb err
		# debug 'activity', 
		unless card then return cb "card not found #{missing++}"
		cards[cardId] = card
		return cb null, card
		

db.activities.find().each (err,activity)->
	unless activity?
		return console.log 'done'
		# process.exit(0)
	unless activity.card then return
	if activity.card._id then return
	cardId = activity.card
	debug 'activity', 'fluffing', activity.id, {card:activity.card}
	getCard activity.project, cardId, (err, card) ->
		if err?
			logError "activity", activity.id, "project", activity.project, "card", cardId, err
			if err.match /card not found.*/ then logError err, 'deleting that shit'
			activity.remove()
			return
		activity.card = {_id: card._id, number: card.number}
		activity.markModified 'card'
		activity.save()
