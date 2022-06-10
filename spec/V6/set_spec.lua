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
end)