local sort = require('template.utils.sort')

-- Data structure for all the `func` declarations.
-- This custom data structure smartly handles func priorities, so the order
-- they're declared in mods.xml is respected no matter what.
-- This data structure is generic enough to be used for any context, but
-- that is not the case for now.
local M = {}

function M:add(obj)
	local stage = self.stage
	self.n = self.n + 1
	stage.n = stage.n + 1
	stage[stage.n] = obj
end

function M:remove()
	local swap = self.swap
	swap[swap.n] = nil
	swap.n = swap.n - 1
	self.n = self.n - 1
end

function M:next()
	if self.n == 0 then
		return
	end

	local swap = self.swap
	local stage = self.stage
	local list = self.list

	if swap.n == 0 then
		sort.stable_sort(stage, self.reverse_comparator)
	end
	if stage.n == 0 then
		if list.n == 0 then
			while swap.n ~= 0 do
				list.n = list.n + 1
				list[list.n] = swap[swap.n]
				swap[swap.n] = nil
				swap.n = swap.n - 1
			end
		else
			swap.n = swap.n + 1
			swap[swap.n] = list[list.n]
			list[list.n] = nil
			list.n = list.n - 1
		end
	else
		if list.n == 0 then
			swap.n = swap.n + 1
			swap[swap.n] = stage[stage.n]
			stage[stage.n] = nil
			stage.n = stage.n - 1
		else
			if self.comparator(list[list.n], stage[stage.n]) then
				swap.n = swap.n + 1
				swap[swap.n] = list[list.n]
				list[list.n] = nil
				list.n = list.n - 1
			else
				swap.n = swap.n + 1
				swap[swap.n] = stage[stage.n]
				stage[stage.n] = nil
				stage.n = stage.n - 1
			end
		end
	end
	return swap[swap.n]
end

local mt = { __index = M }

function M.new(comparator)
	return setmetatable({
		comparator = comparator,
		reverse_comparator = function(a, b)
			return comparator(b, a)
		end,
		stage = { n = 0 },
		list = { n = 0 },
		swap = { n = 0 },
		n = 0,
	}, mt)
end

return M
