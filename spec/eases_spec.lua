---@diagnostic disable: undefined-global
local helper = require("spec.helper")
local update = helper.update

local function check_doesnt_crash(fn)
	for i = 0, 1, 0.2 do
		fn(i)
	end
end

local function check_permenant(fn)
	check_doesnt_crash(fn)
	assert(fn(1) > 0.5)
end

local function check_transient(fn)
	check_doesnt_crash(fn)
	assert(fn(1) < 0.5)
end

describe("eases", function()
	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)

	it("should have quad functions", function()
		check_permenant(xero.inQuad)
		check_permenant(xero.outQuad)
		check_permenant(xero.inOutQuad)
		check_permenant(xero.outInQuad)
	end)

	it("should have cubic functions", function()
		check_permenant(xero.inCubic)
		check_permenant(xero.outCubic)
		check_permenant(xero.inOutCubic)
		check_permenant(xero.outInCubic)
	end)

	it("should have quart functions", function()
		check_permenant(xero.inQuart)
		check_permenant(xero.outQuart)
		check_permenant(xero.inOutQuart)
		check_permenant(xero.outInQuart)
	end)

	it("should have quint functions", function()
		check_permenant(xero.inQuint)
		check_permenant(xero.outQuint)
		check_permenant(xero.inOutQuint)
		check_permenant(xero.outInQuint)
	end)

	it("should have expo functions", function()
		check_permenant(xero.inExpo)
		check_permenant(xero.outExpo)
		check_permenant(xero.inOutExpo)
		check_permenant(xero.outInExpo)
	end)

	it("should have circ functions", function()
		check_permenant(xero.inCirc)
		check_permenant(xero.outCirc)
		check_permenant(xero.inOutCirc)
		check_permenant(xero.outInCirc)
	end)

	it("should have back functions", function()
		check_permenant(xero.inBack)
		check_permenant(xero.outBack)
		check_permenant(xero.inOutBack)
		check_permenant(xero.outInBack)
	end)

	it("should have elastic functions", function()
		check_permenant(xero.inElastic)
		check_permenant(xero.outElastic)
		check_permenant(xero.inOutElastic)
		check_permenant(xero.outInElastic)
	end)

	it("should have .param", function()
		check_permenant(xero.inElastic:params(1, 1))
		check_permenant(xero.outElastic:params(1, 0.5))
		check_permenant(xero.inOutElastic:params(1.2, 1.2))
		check_permenant(xero.outInElastic:params(1.3, 1))
		assert.not_equal(xero.inOutElastic:params(1.3, 0.2)(0.3), xero.inOutElastic:params(1.4, 1)(0.3))
	end)

	it("should have other misc functions", function()
		check_transient(xero.bounce)
		check_transient(xero.tri)
		check_transient(xero.bell)
		check_transient(xero.pop)
		check_transient(xero.tap)
		check_transient(xero.pulse)
		check_transient(xero.inverse)
	end)

	it("should have flip", function()
		check_permenant(xero.outExpo)
		check_transient(xero.flip(xero.outExpo))
	end)

	it("should have blendease", function()
		check_permenant(xero.blendease(xero.outExpo, xero.inExpo))
	end)

	it("should throw the right errors when calling blendease", function()
		assert.errors(function() xero.blendease(xero.outExpo, xero.pop) end)
		assert.errors(function() xero.blendease(xero.pop, xero.inExpo) end)
	end)
end)
