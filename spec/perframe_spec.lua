---@diagnostic disable: undefined-global
local helper = require("spec.helper")
local update = helper.update

describe("perframe", function()
	before_each(function()
		helper.reset()
		helper.init()
	end)

	after_each(function()
		xero = nil
	end)

	it("should be concerningly pedantic about run order", function()
		-- beat order only affects when things are run
		-- the in-frame order is entirely determined on the order perframe was called
		-- defer=true means to run after the defer=false, and runs in reverse call order
		local order = 0
		xero.perframe {3, 4, function(beat)
			if beat == 4 then
				assert.equal(2, order)
				order = 3
			elseif beat == 6 then
				assert.equal(6, order)
				order = 7
			else
				error("bad beat")
			end
		end}
		xero.perframe {1, 4, function(beat)
			if beat == 2 then
				assert.equal(0, order)
				order = 1
			elseif beat == 4 then
				assert.equal(3, order)
				order = 4
			else
				error("bad beat")
			end
		end}
		xero.perframe {1, 6, function(beat)
			if beat == 2 then
				assert.equal(1, order)
				order = 2
			elseif beat == 4 then
				assert.equal(5, order)
				order = 6
			elseif beat == 6 then
				assert.equal(8, order)
				order = 9
			else
				error("bad beat")
			end
		end, defer = true}
		xero.perframe {3, 4, function(beat)
			if beat == 4 then
				assert.equal(order, 4)
				order = 5
			elseif beat == 6 then
				assert.equal(order, 7)
				order = 8
			else
				error("bad beat")
			end
		end}

		update(2)
		update(2)
		helper.update(2)
		assert.equal(order, 9)
	end)

	it("should require curly braces", function()
		assert.errors(function() xero.perframe("haha, no curly") end)
	end)

	it("should detect missing beats", function()
		assert.errors(function() xero.perframe {nil, 1, function() end} end)
	end)

	it("should detect missing length", function()
		assert.errors(function() xero.perframe {1, nil, function() end} end)
	end)

	it("should detect missing functions", function()
		assert.errors(function() xero.perframe {nil, 1, nil} end)
	end)

	it("should have proper persist semantics", function()
		local count = 0
		local function no()
			assert(false, "this shouldn\'t have run")
		end
		local function yes()
			assert(true, "this should run")
			count = count + 1
		end
		-- frame is on beat 6
		xero.perframe {0, 0, no}
		xero.perframe {0.5, 3, no}
		xero.perframe {0, 0, no, persist = 5}
		xero.perframe {2, 0, no, persist = 3}
		-- xero.perframe {3, 4, no, persist = 5, mode = 'end'}
		xero.perframe {0, 0, yes, persist = true}
		xero.perframe {0, 1, yes, persist = 5}
		xero.perframe {1, 2, yes, persist = 3}
		xero.perframe {2, 0, yes, persist = 4}
		xero.perframe {3, 4, yes, persist = 6.5, mode = "end"}
		update(5.75)

		assert.equal(5, count, "Not all persists persisted")
	end)

	it("shouldn\'t allow poptions and persist", function()
		assert.errors(function()
			xero.perframe {0, 1, function(_, poptions)
				local _ = poptions[1].invert
			end, persist = true}
			update(0.5)
			update(0.5)
			update(0.5)
		end)
	end)
end)
