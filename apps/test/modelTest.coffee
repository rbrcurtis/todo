log 'modeltest'

describe 'model', ->
	CONFIG.debug.push 'model'
	Model = require 'lib/db/rally/models/framework/Model'
	class Foo extends Model
		@attributes:
			foo:
				type: String
				set: (val) ->
					return val+'bar'
				get: (val) ->
					return val+'baz'
				validate: (val) ->
					return val is 'foobar'
			bar: 
				type: [Number]

	it 'has working set and get', ->
		foo = new Foo foo:'foo'
		assert.equal foo.foo, 'foobarbaz'
		
	it 'validates', ->
		assert.throws (->new Foo foo:'bar'), ''
			
	it 'can handle array types', ->
		foo = new Foo foo:'foo', bar:[1,2]
		assert foo.bar instanceof Array
		# bar needs to be an array
		assert.throws (-> foo = new Foo foo:'foo', bar:'pew'), ''
		# bar can only contain numbers
		assert.throws (-> foo = new Foo foo:'foo', bar:['pew', 'pew', 1]), ''
