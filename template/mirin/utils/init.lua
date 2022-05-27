local M = {}

--- Returns a shallow copy of the table `src`
local function copy(src)
	local dest = {}
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end
M.copy = copy

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

-- Move global functions to the xero table, allowing for slightly faster
-- performance due to not having to go back and forth between xero and _G.
xero.xero = _G.xero
xero.type = _G.type
xero.print = _G.print
xero.pairs = _G.pairs
xero.ipairs = _G.ipairs
xero.unpack = _G.unpack
xero.tonumber = _G.tonumber
xero.tostring = _G.tostring
xero.math = copy(_G.math)
xero.table = copy(_G.table)
xero.string = copy(_G.string)

return M
