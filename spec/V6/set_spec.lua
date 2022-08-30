---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('set', function()

	before_each(function()
		helper.reset()
		helper.init(true)
	end)

	after_each(function()
		xero = nil
	end)

	it('should set the mod', function()
		xero.set(0, {bumpy = 100})
		update()
		assert.equal('100', helper.get_mod('bumpy'))
	end)

	it('should detect errors', function()
		-- missing beat
		assert.errors(function() xero.set(nil, {bumpy = 100}) end, 'invalid start beat')

		-- missing mods table
		assert.errors(function() xero.set(0, nil) end, 'invalid mods table')

		-- invalid mod name
		assert.errors(function() xero.set(0, {[1] = 100}) end, 'invalid mod: 1')

		-- invalid mod percent
		assert.errors(function() xero.set(0, {bumpy = '100'}) end, 'bumpy has invalid percent')

		-- invalid options table
		assert.errors(function() xero.set(0, {bumpy = 100}, 1) end, 'invalid options table')

		-- invalid plr options
		assert.errors(function() xero.set(0, {bumpy = 100}, {plr = '1'}) end, 'invalid plr option')

		-- not callable after beat 0
		update()
		assert.errors(function() xero.set(0, {bumpy = 100}) end, 'cannot call set after LoadCommand finished')
	end)
end)
