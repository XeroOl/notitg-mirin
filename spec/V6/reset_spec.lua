---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('reset', function()

	before_each(function()
		helper.reset()
		helper.init(true)
	end)

	after_each(function()
		xero = nil
	end)

	it('should reset mods', function()
		xero.set(0, {bumpy = 100})
		xero.reset(1)
		update(2)
		assert.equal('0', helper.get_mod('bumpy'))
	end)

	it('should use the options table', function()
		xero.set(0, {bumpy = 100})
		xero.reset(1, 1, xero.outCirc, {plr = 1})
		xero.reset(3, {plr = 2})
		update(2)
		assert.equal('0', helper.get_mod('bumpy', 1))
		assert.equal('100', helper.get_mod('bumpy', 2))
		update(1)
		assert.equal('0', helper.get_mod('bumpy', 2))
	end)

	it('should have a working only option', function()
		xero.set(0, {bumpy = 100, invert = 100}, {plr = 1})
		xero.set(0, {bumpy = 100, invert = 100}, {plr = 2})
		xero.reset(1, {only = {'bumpy'}, plr = 1})
		xero.reset(1, {only = 'bumpy', plr = 2})
		update(1)
		assert.equal('0', helper.get_mod('bumpy', 1))
		assert.equal('100', helper.get_mod('invert', 1))
		assert.equal('0', helper.get_mod('bumpy', 2))
		assert.equal('100', helper.get_mod('invert', 2))
	end)

	it('should have a working exclude option', function()
		xero.set(0, {bumpy = 100, invert = 100}, {plr = 1})
		xero.set(0, {bumpy = 100, invert = 100}, {plr = 2})
		xero.reset(1, {exclude = {'bumpy'}, plr = 1})
		xero.reset(1, {exclude = 'bumpy', plr = 2})
		update(1)
		assert.equal('100', helper.get_mod('bumpy', 1))
		assert.equal('0', helper.get_mod('invert', 1))
		assert.equal('100', helper.get_mod('bumpy', 2))
		assert.equal('0', helper.get_mod('invert', 2))
	end)

	it('should detect errors', function()
		-- missing start beat
		assert.errors(function() xero.reset(nil) end, 'invalid start beat')
		assert.errors(function() xero.reset(nil, 1, xero.outCirc) end, 'invalid start beat')

		-- missing length
		assert.errors(function() xero.reset(0, nil, xero.outCirc) end, 'invalid length')

		-- missing ease function
		assert.errors(function() xero.reset(0, 1, nil) end, 'invalid ease function')

		-- invalid options table
		assert.errors(function() xero.reset(0, 1, xero.outCirc, 1) end, 'invalid options table')
		assert.errors(function() xero.reset(0, '1') end, 'invalid options table')

		-- invalid plr option
		assert.errors(function() xero.reset(0,{plr = '1'}) end, 'invalid plr option')

		-- mutually exclusive only and exclude
		assert.errors(function() xero.reset(0,{only = 'bumpy', exclude = 'invert'}) end, 'only and exclude options are mutually exclusive')

		-- invalid exclude option
		assert.errors(function() xero.reset(0, {exclude = 1}) end, 'invalid exclude option')

		-- invalid only option
		assert.errors(function() xero.reset(0, {only = 1}) end, 'invalid only option')

		-- not callable after beat 0
		update()
		assert.errors(function() xero.reset(0) end, 'cannot call reset after LoadCommand finished')
	end)

end)
