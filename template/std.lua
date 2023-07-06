-- Environments

-- Create the xero environment, in which everything is
setmetatable(xero, {
	-- if something isn't found in the xero table, fall back to a _G lookup
	__index = _G,

	-- Calling xero() sets the environment of the current function
	-- Calling xero(func) returns `func` with the xero environment applied
	__call = function(self, f)
		setfenv(f or 2, self)
		return f
	end,
})

-- make require work
xero.package = {
	-- mirin template loader path
	path = 'lua/?.lua;lua/?/init.lua;plugins/?.lua;plugins/?/init.lua',
	preload = {
		-- loadfile(xero.dir .. 'template/std.lua'),
	},
	loaded = {},
	loaders = {
		function(modname)
			local preload = xero.package.preload[modname]
			return preload or "no field xero.package.preload['" .. modname .. "']"
		end,
		function(modname)
			local errors = {}
			-- get the filename
			local filename = string.gsub(modname, '%.', '/')
			for path in (string.gfind or string.gmatch)(xero.package.path, '[^;]+') do
				-- get the file path
				local filepath = xero.dir .. string.gsub(path, '%?', filename)
				-- check if file exists
				if not GAMESTATE:GetFileStructure(filepath) then
					table.insert(errors, "no file '" .. filepath .. "'")
				else
					local loader, err = loadfile(filepath)
					-- check if file loads properly
					if err then
						error(err, 3)
					elseif loader then
						return xero(loader)
					end
				end
			end
			return table.concat(errors, '\n')
		end,
	},
}

function xero.require(modname)
	local loaded = xero.package.loaded
	if not loaded[modname] then
		local errors = { "module '" .. modname .. "' not found:" }
		local chunk
		for _, loader in ipairs(xero.package.loaders) do
			local result = loader(modname)
			if type(result) == 'string' then
				table.insert(errors, result)
			elseif type(result) == 'function' then
				chunk = result
				break
			end
		end
		if not chunk then
			error(table.concat(errors, '\n'), 2)
		end
		loaded[modname] = chunk()
		if loaded[modname] == nil then
			loaded[modname] = true
		end
	end
	return loaded[modname]
end

-- Apply the environment. :)
xero()

--- Create the strict environment, forbidding creating any variable
--- This environment is not related to the xero table, and won't fetch
--- values from it, unless explicitely prefixed with `xero.`
xero.strict = setmetatable({}, {
	-- Allow access to _G elements, containing all game methods
	__index = _G,
	-- Prevent creating any variable
	__newindex = function(_self, t)
		error(t)
	end,
})

-- ===================================================================== --

-- Utility functions

--- Returns a shallow copy of the table `src`
function copy(src)
	local dest = {}
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end

-- Clear a table's contents, leaving it empty.
-- Useful for resetting a table containing metatables.
function clear(t)
	for k, v in pairs(t) do
		t[k] = nil
	end
	return t
end

-- Clear a table's contents, when the table only contains 'logical' indexes
-- (as in: contiguous numerical indexes from 1 to #table)
function iclear(t)
	for i = 1, #t do
		t[i] = nil
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

-- ===================================================================== --

-- Data structure for all the `func` declarations.
-- This custom data structure smartly handles func priorities, so the order
-- they're declared in mods.xml is respected no matter what.
-- This data structure is generic enough to be used for any context, but
-- that is not the case for now.

local methods = {}

function methods:add(obj)
	local stage = self.stage
	self.n = self.n + 1
	stage.n = stage.n + 1
	stage[stage.n] = obj
end

function methods:remove()
	local swap = self.swap
	swap[swap.n] = nil
	swap.n = swap.n - 1
	self.n = self.n - 1
end

function methods:next()
	if self.n == 0 then
		return
	end

	local swap = self.swap
	local stage = self.stage
	local list = self.list

	if swap.n == 0 then
		stable_sort(stage, self.reverse_comparator)
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

local mt = { __index = methods }

function perframe_data_structure(comparator)
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
