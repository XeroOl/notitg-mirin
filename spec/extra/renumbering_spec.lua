local helper = require 'spec.helper'
local update = helper.update

describe('extra.renumbering', function()

	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)


	it('should renumber the players if P1 is missing', function()
		for pn = 1, 7, 2 do
			helper.mock().delete_player(pn)
		end

		local s1, s2
		local spy = spy

		helper.putfile('lua/mods.lua', function()
			s1 = spy.on(P2, 'SetInputPlayer')
			s2 = spy.on(P4, 'SetInputPlayer')
			xero.require('extra.renumbering')
		end)

		update()
		assert(xero.P1, 'missing P1')
		assert(xero.P2, 'missing P2')
		assert(xero.P3, 'missing P3')
		assert(xero.P4, 'missing P4')
		assert(not xero.P5, 'P5 should be gone')
		assert(not xero.P6, 'P6 should be gone')
		assert(not xero.P7, 'P7 should be gone')
		assert(not xero.P8, 'P8 should be gone')
		assert(xero.P[1], 'missing P[1]')
		assert(xero.P[2], 'missing P[2]')
		assert(xero.P[3], 'missing P[3]')
		assert(xero.P[4], 'missing P[4]')
		assert(not xero.P[5], 'P[5] should be gone')
		assert(not xero.P[6], 'P[6] should be gone')
		assert(not xero.P[7], 'P[7] should be gone')
		assert(not xero.P[8], 'P[8] should be gone')
		assert.spy(s1).was_called_with(xero.P1, 1)
		assert.spy(s2).was_called_with(xero.P2, 1)
	end)

	it('should renumber the players if P2 is missing', function()
		for pn = 2, 8, 2 do
			helper.mock().delete_player(pn)
		end

		local s1, s2
		local spy = spy

		helper.putfile('lua/mods.lua', function()
			s1 = spy.on(P1, 'SetInputPlayer')
			s2 = spy.on(P3, 'SetInputPlayer')
			xero.require('extra.renumbering')
		end)

		update()
		assert(xero.P1, 'missing P1')
		assert(xero.P2, 'missing P2')
		assert(xero.P3, 'missing P3')
		assert(xero.P4, 'missing P4')
		assert(xero.P[1], 'missing P[1]')
		assert(xero.P[2], 'missing P[2]')
		assert(xero.P[3], 'missing P[3]')
		assert(xero.P[4], 'missing P[4]')
		assert.spy(s1).was_called_with(xero.P1, 0)
		assert.spy(s2).was_called_with(xero.P2, 0)
	end)

end)
