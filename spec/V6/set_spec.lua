---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('set', function()

	before_each(function()
		helper.reset()
		helper.init(false, true)
	end)
	after_each(function()
		xero = nil
	end)

	it('should set the mod', function()
		xero.set(0,{bumpy = 100})
		update()
		assert.equal('100', helper.get_mod('bumpy'))
	end)

	it('should detect missing beat', function()
		assert.errors(function() xero.set(nil, {bumpy = 100}) end, 'invalid start beat')
	end)

	it('should detect missing mods table', function()
		assert.errors(function() xero.set(0, nil) end, 'invalid mods table')
	end)

	it('should detect invalid mod names', function()
		assert.errors(function() xero.set(0, {[1] = 100}) end, 'invalid mod: 1')
	end)

	it('should detect invalid mod percents', function()
		assert.errors(function() xero.set(0, {bumpy = '100'}) end, 'bumpy has invalid percent')
	end)

	it('should detect invalid options table', function()
		assert.errors(function() xero.set(0, {bumpy = 100}, 1) end, 'invalid options table')
	end)

	it('should detect invalid plr options', function()
		assert.errors(function() xero.set(0, {bumpy = 100}, {plr = '1'}) end, 'invalid plr option')
	end)

	it('should not be callable after beat 0', function()
		update()
		assert.errors(function() xero.set(0, {bumpy = 100}) end, 'cannot call set after LoadCommand finished')
	end)
end)