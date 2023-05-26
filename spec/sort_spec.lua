---@diagnostic disable: undefined-global
local helper = require("spec.helper")
local update = helper.update

describe("sort", function()
	setup(function()
		helper.reset()
		helper.init()
	end)

	it("should not unsort a sorted table", function()
		local testtable = {}
		local checktable = {}
		for i = 1,100 do
			table.insert(testtable,i)
			table.insert(checktable,i)
		end
		xero.stableSort(testtable,function(a, b) return a < b end)
		assert.is.same(testtable, checktable)
	end)

	it("should sort an unsorted table", function()
		local testtable = {1,1000,4,5,2,45,3,6,7,8,16,57,10,11,12,69,13,14,15,9,79,1,1,1000,4,5,2,45,3,6,7,8,16,57,10,11,12,69,13,14,15,9,79,1}
		xero.stableSort(testtable,function(a, b) return a < b end)
		assert.is.same(testtable, {1,1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,45,45,57,57,69,69,79,79,1000,1000})
	end)
end)