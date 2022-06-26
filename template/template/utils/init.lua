local M = {}

--- Returns a shallow copy of the table `src`
function M.copy(src)
	local dest = {}
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end

-- Clear a table's contents, leaving it empty.
-- Useful for resetting a table containing metatables.
function M.clear(t)
	for k, v in pairs(t) do
		t[k] = nil
	end
	return t
end

-- Clear a table's contents, when the table only contains 'logical' indexes
-- (as in: contiguous numerical indexes from 1 to #table)
function M.iclear(t)
	for i = 1, #t do
		table.remove(t)
	end
	return t
end

--- Spill every value in table `t` into the global environment.
----@param t the table
function M.spill(t)
	for k, v in pairs(t) do
		xero[k] = v
	end
	return M.spill
end

return M
