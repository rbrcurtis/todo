db = require 'lib/db'

db.users.getById '4f54e80bece0c060aa8f000c', (err, nate) =>
	db.projects.getById '503643321ccfcccaa06d0003', (err, p)=>
		i = p.roles[1].members.indexOf nate._id
		p.roles[1].members.splice i, 1
		# p.roles[0].members.push ryan
		p.save()
		

		# for u in users
			# inthere = console.log if p.roles[1].members.indexOf(u._id)>=0 then true else false
			# unless inthere
				# p.roles[1].members.push u
		# console.log p.roles[1].members
		# p.save()
