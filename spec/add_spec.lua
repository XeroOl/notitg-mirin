---@diagnostic disable: undefined-global
local helper = require "spec.helper"
local update = helper.update

describe("add", function()
	before_each(function()
		helper.reset(); helper.init()
	end)
	after_each(function() xero = nil end)

	it("should add to the amount", function()
		xero.add {0, 4, xero.inOutExpo, 100, "bumpyx"}
		xero.add {0, 4, xero.inOutExpo, 100, "bumpyx"}
		xero.add {0, 4, xero.inOutExpo, 100, "bumpyx"}
		update(4)
		assert.equal("300", helper.get_mod("bumpyx"))
	end)
	it("should be player specific", function()
		xero.add {0, 1, xero.outExpo, 100, "dizzy"}
		xero.add {0, 1, xero.outExpo, 100, "dizzy", plr = 1}
		xero.add {0, 1, xero.outExpo, 100, "dizzy", plr = {1, 2}}
		xero.add {0, 1, xero.outExpo, -100, "dizzy", plr = 2}
		update(1)
		assert.equal("300", helper.get_mod("dizzy", 1))
		assert.equal("100", helper.get_mod("dizzy", 2))
	end)
	it("should detect missing beats", function()
		assert.errors(function() xero.add {nil, 4, xero.inOutExpo, 100, "bumpyx"} end)
	end)
	it("should detect missing lengths", function()
		assert.errors(function() xero.add {0, nil, xero.inOutExpo, 100, "bumpyx"} end)
	end)
	it("should detect missing eases", function()
		assert.errors(function() xero.add {0, 4, nil, 100, "bumpyx"} end)
	end)
	it("should detect missing mod percents", function()
		assert.errors(function() xero.add {0, 4, xero.inOutExpo, nil, "bumpyx"} end)
	end)
	it("should detect missing mod names", function()
		assert.errors(function() xero.add {0, 4, xero.inOutExpo, 0, nil} end)
	end)
	it("should detect malformed mod names", function()
		assert.errors(function()
			xero.add {0, 4, xero.inOutExpo, 0, "bumpyx,"}
			update()
		end)
	end)
end)
