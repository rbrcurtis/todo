Channel   = require './Channel'
RabbitBus = require './RabbitBus'
KafkaBus  = require './KafkaBus'

rabbitBus = new RabbitBus()
kafkaBus  = new KafkaBus()

module.exports =
	requests:       new Channel(rabbitBus, 'zen.requests')
	activities:     new Channel(rabbitBus, 'zen.activities')
	events:         new Channel(rabbitBus, 'zen.activities', 'events', {})
	invites:        new Channel(rabbitBus, 'zen.invites', 'invites', {durable:true, autoDelete: false})
	retrievals:     new Channel(rabbitBus, 'zen.retrievals', 'retrievals', {durable:true, autoDelete: false})
	search:         new Channel(rabbitBus, 'zen.activities', 'search', {durable: true, autoDelete: false})
	welcome:        new Channel(rabbitBus, 'zen.welcome', 'welcome', {durable: true, autoDelete: false})
	test:           new Channel(rabbitBus, 'zen.test', 'test')
	migrations:     new Channel(rabbitBus, 'zen.migrations', 'migrator', {durable: true, autoDelete: false})
	fileMigrations: new Channel(rabbitBus, 'zen.fileMigrations', 'fileMigrator', {durable: true, autoDelete: false})

	artifacts:      new Channel(kafkaBus, 'artifacts', 0, {})
