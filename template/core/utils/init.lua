local M = {}

--- Returns a shallow copy of the table `src`
function M.copy(src, dest)
	dest = dest or {}
	for k, v in pairs(src) do
		rawset(dest, k, v)
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

return M
