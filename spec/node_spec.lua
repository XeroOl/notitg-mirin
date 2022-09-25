---@diagnostic disable: undefined-global
local helper = require 'spec.helper'
local update = helper.update

describe('node', function()
	before_each(function() helper.reset(); helper.init() end)
	after_each(function() xero = nil end)

	it('should pass values, add current mod values, and run provided function', function()
		local testvar = 0
		xero.node {'beat', function(beat)
			testvar = beat
			return beat, beat
		end, 'bumpy', 'zigzag'}

		xero.set {1, 100, 'beat', 100, 'zigzag'}

		update()

		assert.equal('0', helper.get_mod('bumpy'))
		assert.equal('0', helper.get_mod('zigzag'))
		assert.equal(0, testvar)

		update(1)

		assert.equal('100', helper.get_mod('bumpy'))
		assert.equal('200', helper.get_mod('zigzag'))
		assert.equal(100, testvar)
	end)

	it('should supports short hand syntax', function()
		xero.node {'beat', 2, 'bumpy'}
		xero.set {0, 100, 'beat'}
		update(0)
		assert.equal('200', helper.get_mod('bumpy'))
	end)

	it('should support multiple players', function()
		xero.node {'beat', 2, 'bumpy'}
		xero.set {0, 100, 'beat', plr = 1}
		xero.set {0, 200, 'beat', plr = 2}

		update()

		assert.equal('200', helper.get_mod('bumpy', 1))
		assert.equal('400', helper.get_mod('bumpy', 2))

	end)

	it('should sort arbitrary sort order', function()
		xero.aux {'a', 'b', 'c'}
		xero.node {'c', function(c) return c end, 'd'}
		xero.node {'a', function(a) return a end, 'b'}
		xero.node {'f', function(f) return f end, 'g'}
		xero.node {'b', function(b) return b end, 'c'}
		xero.node {'d', function(d) return d end, 'e'}

		xero.alias {'e', 'f'}

		xero.set {0, 100, 'a'}

		update()

		assert.equal('100', helper.get_mod('g'))
	end)
end)
