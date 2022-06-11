---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('mod', function()

	before_each(function()
		helper.reset()
		helper.init(false, true)
	end)

	after_each(function()
		xero = nil
	end)

	it('should be callable', function()
		xero.mod(0, 1, xero.outCirc, {bumpy = 100})
	end)

	it('should ease the mod value', function()
		xero.mod(0, 1, xero.outCirc, {bumpy = 100})
		for i = 1, 60 do
			update(1/60)
			assert.equal(helper.round(xero.outCirc(i/60) * 100, 5), helper.round(helper.get_mod('bumpy'), 5))
		end
		assert.equal('100', helper.get_mod('bumpy'))
	end)

	it('should be player specific', function()
		xero.mod(0, 0, xero.instant, {bumpy = 100}, {plr = 1})
		xero.mod(0, 0, xero.instant, {bumpy = -100}, {plr = 2})
		xero.mod(1, 0, xero.instant, {bumpy = 0}, {plr = {1, 2}})
		update()
		assert.equal('100', helper.get_mod('bumpy', 1))
		assert.equal('-100', helper.get_mod('bumpy', 2))
		update(1)
		assert.equal('0', helper.get_mod('bumpy', 1))
		assert.equal('0', helper.get_mod('bumpy', 2))
	end)

	it('should have working mode option', function()
		xero.mod(0, 5, xero.outCirc, {bumpy = 100, invert = 100})
		xero.mod(5, 10, xero.outCirc, {bumpy = 0}, {mode = 'end'})
		xero.mod(5, 10, xero.outCirc, {invert = 0}, {mode = 'e'})
		update(10)
		assert.equal('0', helper.get_mod('bumpy'))
		assert.equal('0', helper.get_mod('invert'))
	end)

	it('should have working time option', function()
		pending('figure out how to make a good case for this with xero')
		xero.mod(0, 1, xero.outCirc, {bumpy = 100}, {time = true})
		update(1)
		assert.equal('100', helper.get_mod('bumpy'))
	end)

	it('should detect errors', function()
		-- missing beat
		assert.errors(function() xero.mod(nil, 1, xero.outCirc, {bumpy = 100}) end, 'invalid start beat')

		-- missing length
		assert.errors(function() xero.mod(0, nil, xero.outCirc, {bumpy = 100}) end, 'invalid length')

		-- missing ease function
		assert.errors(function() xero.mod(0, 1, nil, {bumpy = 100}) end, 'invalid ease function')
			
		-- missing mods table
		assert.errors(function() xero.mod(0, 1, xero.outCirc, nil) end, 'invalid mods table')

		-- invalid mod name
		assert.errors(function() xero.mod(0, 1, xero.outCirc, {[1] = 100}) end, 'invalid mod: 1')

		-- invalid mod percent
		assert.errors(function() xero.mod(0, 1, xero.outCirc, {bumpy = '100'}) end, 'bumpy has invalid percent')

		-- invalid option table
		assert.errors(function() xero.mod(0, 1, xero.outCirc, {bumpy = 100}, 1) end, 'invalid options table')

		-- invalid plr option
		assert.errors(function() xero.mod(0, 1, xero.outCirc, {bumpy = 100}, {plr = '1'}) end, 'invalid plr option')

		-- not callable after beat 0
		update()
		assert.errors(function() xero.mod(0, 0, xero.instant, {bumpy = 100}) end, 'cannot call mod after LoadCommand finished')
	end)

end)