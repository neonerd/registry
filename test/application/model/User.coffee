counter = 0

module.exports = {

	foo : () ->

		return 'foo'

	bar : () ->

		return 'bar'

	persistence : () ->

		counter++
		return counter

}