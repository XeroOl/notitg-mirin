---@diagnostic disable: undefined-global
local helper = require 'spec.helper'
local update = helper.update

describe('mirin template', function()

	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)

	it('should load', function()
		helper.on()
		helper.update()
	end)

	it('should stop you from calling functions after tables are sorted', function()
		update()
		assert.errors(function() xero.ease {0, 1, xero.outExpo, 100, 'invert'} end)
		assert.errors(function() xero.add {0, 1, xero.outExpo, 100, 'invert'} end)
		assert.errors(function() xero.set {0, 100, 'invert'} end)
		assert.errors(function() xero.acc {0, 100, 'invert'} end)
		assert.errors(function() xero.func {0, function() end} end)
		assert.errors(function() xero.perframe {0, 10, function() end} end)
		assert.errors(function() xero.func_ease {0, 1, xero.outExpo, 0, 1, function() end} end)
		assert.errors(function() xero.alias {'mod_a', 'mod_b'} end)
		assert.errors(function() xero.setdefault {0, 'bumpy'} end)
		assert.errors(function() xero.aux {'bumpyxy'} end)
		assert.errors(function() xero.node {'invert', function() end} end)
		assert.errors(function() xero.definemod {'invert', function() end} end)
	end)

	it('should detect Name= actors', function()
		helper.on()
		assert(
			xero.PP and xero.PP[1] and xero.PP[2] and
			xero.PJ and xero.PJ[1] and xero.PJ[2] and
			xero.PC and xero.PC[1] and xero.PC[2],
			'actors aren\'t present'
		)
	end)
end)
