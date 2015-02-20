# -- dependencies

chai = require "chai"
registry = require "../src"

# -- test tools

expect = chai.expect;

# -- TESTS

describe 'when registering a namespace', () ->

	it 'should register the namespace if everything is correct (string path)', () ->

		registry.register 'correct_models', __dirname + '/application/model'

	it 'should register the namespace if everything is correct (array of paths)', () ->

		registry.register 'correct_array_models', [__dirname + '/application/model', __dirname + '/application/additional_model']

	it 'should not register the namespace if it contains the namespace separator in its name', () ->

		expect () ->

			registry.register 'incorrect:name', __dirname + '/application/model'

		.to.throw()

	it 'should not register the namespace if the name already exists', () ->

		registry.register 'already_models', __dirname + '/application/model'

		expect () ->
			registry.register 'already_models', __dirname + '/application/model'
		.to.throw()

	it 'should not register the namespace if the path does not exist', () ->

		expect () ->
			registry.register 'not_existing_models', __dirname + '/application/models'
		.to.throw()

	it 'should not register the namespace if the path is relative', () ->

		expect () ->
			registry.register 'relative_models', './application/model'
		.to.throw()

	it 'should not register the namespace if the paths contain two modules that are same', () ->

		expect () ->

			registry.register 'duplicate_models', [__dirname + '/application/model', __dirname + '/application/controllers']

		.to.throw()

describe 'when loading a module', () ->

	it 'should load the module correctly', () ->

		registry.register 'models', __dirname + '/application/model'
		service = registry.load 'models:User'

		expect(service.foo()).to.equal('foo')

	it 'should throw an error if the namespace does not exist', () ->

		expect () ->

			service = registry.load 'modelsss:User'

		.to.throw()

	it 'should throw an error if the module does not exist', () ->

		expect () ->

			registry.register 'models_that_dont_exist', __dirname + '/application/model'
			service = registry.load 'models_that_dont_exist:Usersss'

		.to.throw()

	it 'should work persistently', () ->

		registry.register 'persistent_models', __dirname + '/application/model'
		service = registry.load 'persistent_models:User'

		expect(service.persistence()).to.equal(1)

		service = registry.load 'persistent_models:User'

		expect(service.persistence()).to.equal(2)