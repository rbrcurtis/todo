Filter = require './framework/Filter'

db = require 'lib/db'
error = require 'lib/error'

module.exports = class EnsureIsListOwnerFilter extends Filter
	
	before: (success, failure) ->
		db.lists.getById @request.params.list, (err, list) =>
			if err? then return failure err
			if not list? then return failure error.notFound()
			
			if list.hasOwner(@user._id)
				return success()
				
			return failure error.forbidden()
	
