module.exports = class MessageFactory

	create: (msg) ->
		log "this is updates"
		
		if msg.changes?.updated?
			
			log "updates happening"
				
			message =
				user:      msg.user
				timestamp: msg.finished
				changes:   []
				
			for change in msg.changes.updated
				for key,val of change.document
					if not change.previous[key]?
						delete change.document[key]
				
				message.changes.push change
				
				
			return message
			
		else return null
	
