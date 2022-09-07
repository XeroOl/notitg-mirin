---@diagnostic disable: undefined-global
local helper = require 'spec.helper'
local update = helper.update

describe('newnode', function()
	before_each(function() helper.reset(); helper.init() end)
	after_each(function() xero = nil end)

	it('should sort the node graph to handle out of order dependencies', function()
		xero.node {'beat', function(a, pn)
			return a
		end, 'drunk'}

		xero.node {'bumpy', function(a, pn)
			return a
		end, 'beat'}

		xero.node {'drunk', function(a, pn)
			return a
		end, 'zigzag'}

		xero.set {0, 100, 'bumpy'}

		update(1)

		assert.equal('100', helper.get_mod('zigzag'))
	end)
end)
