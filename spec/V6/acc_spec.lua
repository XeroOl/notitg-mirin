---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('acc', function()

	before_each(function()
		helper.reset()
		helper.init(false, true)
	end)

	after_each(function()
		xero = nil
	end)

	it('should add mod values', function()
		xero.acc(0, {bumpy = 100})
		xero.acc(1, {bumpy = 100})
		xero.acc(2, {bumpy = 100})
		xero.acc(3, {bumpy = 100})
		update(4)
		assert.equal('400', helper.get_mod('bumpy'))
	end)

	it('should use options', function()
		xero.acc(0, {bumpy = 100}, {plr = 1})
		update()
		assert.equal('100', helper.get_mod('bumpy', 1))
		assert.equal(nil, helper.get_mod('bumpy', 2))
	end)

	it('should throw errors', function()
		assert.errors(function() xero.acc() end)
	end)
	
end)