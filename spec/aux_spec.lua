---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('aux', function()

	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)

	it('prevents mods from being applied to the game', function()
		xero.aux {'funny'}
		xero.set {0, 100, 'funny', 100, 'funny2'}

		local funny_observed
		local funny2_observed

		xero.perframe {0, 2, function(_, poptions)
			funny_observed = poptions[1].funny
			funny2_observed = poptions[1].funny2
		end}

		update(1)

		-- funny should show up in a func, but not in the helper's mods model
		assert.equals(nil, helper.get_mod('funny'))
		assert.equals(100, funny_observed)

		-- funny2, having not been auxed, should appear in both
		assert.equals('100', helper.get_mod('funny2'))
		assert.equals(100, funny2_observed)
	end)

	it('works with setdefault', function()
		xero.aux {'funny'}
		xero.setdefault {100, 'funny', 100, 'funny2'}

		update(1)

		assert.equals(nil, helper.get_mod('funny'))
		assert.equals('100', helper.get_mod('funny2'))
	end)

	it('disables the mod name checks', function()
		xero.aux {"invert,"}

		xero.ease {0, 1, xero.outExpo, 100, "invert,"}

		update(1)
	end)

end)
