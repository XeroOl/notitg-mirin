---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('set', function()

	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)

	it('sets values at the right time', function()
		xero.set {1, 100, 'bumpy'}
		update(0.5)
		assert.equal(nil, helper.get_mod('bumpy'))
		update(1)
		assert.equal('100', helper.get_mod('bumpy'))
	end)

	it('it errors with this particular bad signature', function()
		assert.errors(function()
			xero.set {0, nil, 'modname'}
		end)
	end)

end)
