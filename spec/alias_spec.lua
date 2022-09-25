---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('alias', function()

	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)

	it('should work with ease', function()
		xero.alias {'a', 'b'}
		xero.ease {0, 100, xero.outExpo, 100, 'a'}
		update(100)
		assert.equal(helper.get_mod('b'), '100')
	end)

	it('should work with perframes', function()
		local success = false

		xero.alias {'a', 'b'}
		xero.setdefault {100, 'a'}
		xero.perframe {1, 5, function(beat, mods)
			assert.equal(100, mods[1].a)
			assert.equal(100, mods[1].b)
			success = true
		end}
		update(3)
		assert(success, 'perframe did not run when expected')
	end)

	it('should work with definemod (simple case)', function()
		xero.definemod {'a', function()
			return 100
		end, 'b'}
		xero.definemod {'c', function(input)
			return input + 50
		end, 'd'}
		xero.definemod {'e', function(input)
			return input + 25
		end, 'f'}

		xero.alias {'b', 'c'}
		xero.alias {'e', 'd'}
		xero.alias {'f', 'g'}

		xero.set {0, 0, 'a'}

		update(1)
		assert.equal(helper.get_mod('g'), '175')
	end)

end)
