Channel   = require './Channel'
RabbitBus = require './RabbitBus'

rabbitBus = new RabbitBus()

module.exports =
	requests:       new Channel(rabbitBus, 'todo.requests')
	activities:     new Channel(rabbitBus, 'todo.activities')
	events:         new Channel(rabbitBus, 'todo.activities', 'events', {})
	invites:        new Channel(rabbitBus, 'todo.invites', 'invites', {durable:true, autoDelete: false})
	retrievals:     new Channel(rabbitBus, 'todo.retrievals', 'retrievals', {durable:true, autoDelete: false})
	search:         new Channel(rabbitBus, 'todo.activities', 'search', {durable: true, autoDelete: false})
	welcome:        new Channel(rabbitBus, 'todo.welcome', 'welcome', {durable: true, autoDelete: false})
	test:           new Channel(rabbitBus, 'todo.test', 'test')
	migrations:     new Channel(rabbitBus, 'todo.migrations', 'migrator', {durable: true, autoDelete: false})
	fileMigrations: new Channel(rabbitBus, 'todo.fileMigrations', 'fileMigrator', {durable: true, autoDelete: false})
