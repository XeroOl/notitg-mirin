---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('func', function()

	before_each(function()
		helper.reset()
		helper.init(false, true)
	end)

	after_each(function()
		xero = nil
	end)

	it('should run functions', function()
		local ran = false
		xero.func(0, function() ran = true end)
		update()
		assert.equal(true, ran)
	end)

	it('should have working persist option', function()
		local ran = false
		xero.func(0, function() ran = true end, {persist = 2})
		xero.func(0, function() ran = false end, {persist = false})
		update(2)
		assert.equal(true, ran)
	end)

	it('should have working mode option', function()
		local ran = false
		xero.func(1, function() ran = true end, {persist = 2, mode = 'len'})
		xero.func(1, function() ran = false end, {persist = 2, mode = 'end'})
		update(3)
		assert.equal(true, ran)
	end)

	it('should have working time option', function()
		pending('need to talk with xero how to make better time based tests')
	end)

	it('should detect errors', function()
		-- missing beat
		assert.errors(function() xero.func(nil, function() end) end, 'invalid start beat')

		-- missing function
		assert.errors(function() xero.func(0, nil) end, 'invalid function')

		-- invalid options table
		assert.errors(function() xero.func(0, function() end, 1) end, 'invalid options table')

		-- not callable after beat 0
		update()
		assert.errors(function() xero.func(0, function() end) end, 'cannot call func after LoadCommand finished')
	end)

end)
