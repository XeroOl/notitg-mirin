local M = {}
local iclear = require('mirin.utils').iclear
-- the behavior of a stringbuilder
local stringbuilder_mt =  {
	__index = {
		-- :build() method converts a stringbuilder into a string, with optional delimiter
		build = table.concat,
		-- :clear() method empties the stringbuilder
		clear = iclear,
	},

	-- calling a stringbuilder appends to it
	__call = function(self, a)
		table.insert(self, tostring(a))
		return self
	end,

	-- stringbuilder can convert to a string
	__tostring = table.concat,
}

-- stringbuilder constructor
function M.new()
	return setmetatable({}, stringbuilder_mt)
end

return M
