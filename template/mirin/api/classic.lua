local M = {}

local commands = require('mirin.commands')
local mirin = require('mirin')
local max_pn = require('mirin.options').max_pn

local utils = require('mirin.utils')
local instant = require('mirin.api.eases').instant

local stringbuilder = require('mirin.utils.stringbuilder')

local song = GAMESTATE:GetCurrentSong()

-- the `plr=` system
local default_plr = { 1, 2 }

-- for reading the `plr` variable from the xero environment
-- without falling back to the global table
local function get_plr()
	return rawget(xero, 'plr') or default_plr
end

-- ===================================================================== --

-- Error Checking

local function is_valid_ease(eas)
	local err = type(eas) ~= 'function' and (not getmetatable(eas) or not getmetatable(eas).__call)
	if not err then
		local result = eas(1)
		err = type(result) ~= 'number'
	end
	return not err
end

local function check_ease_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	if type(self[1]) ~= 'number' then
		return 'beat missing'
	end
	local is_set = name == 'set' or name == 'acc'
	if not is_set then
		if type(self[2]) ~= 'number' then
			return 'len / end missing'
		end
		if not is_valid_ease(self[3]) then
			return 'invalid ease function'
		end
	end
	local i = is_set and 2 or 4
	while self[i] do
		if type(self[i]) ~= 'number' then
			return 'invalid mod percent'
		end
		if type(self[i + 1]) ~= 'string' then
			return 'invalid mod'
		end
		i = i + 2
	end
	assert(self[i + 1] == nil, 'invalid mod percent: ' .. tostring(self[i]))
	local plr = self.plr or get_plr()
	if type(plr) ~= 'number' and type(plr) ~= 'table' then
		return 'invalid plr'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_reset_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	if type(self[1]) ~= 'number' then
		return 'the first argument needs to be a number in beats'
	end
	if self[2] and self[3] then
		if type(self[2]) ~= 'number' then
			return 'invalid length'
		end
		if not is_valid_ease(self[3]) then
			return 'invalid ease'
		end
	elseif self[2] or self[3] then
		return 'needs both length and ease'
	end
	if type(self.exclude) ~= 'nil' and type(self.exclude) ~= 'string' and type(self.exclude) ~= 'table' then
		return 'invalid `exclude=` value: ' .. tostring(self.exclude)
	end
	if type(self.only) ~= 'nil' and type(self.only) ~= 'string' and type(self.only) ~= 'table' then
		return 'invalid `only=` value: `' .. tostring(self.only)
	end
	if self.exclude and self.only then
		return 'exclude= and only= are mutually exclusive'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_func_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	local beat, fn = self[1], self[2]
	if type(beat) ~= 'number' then
		return 'the first argument needs to be a number in beats'
	end
	if type(fn) ~= 'function' and type(fn) ~= 'string' then
		return 'the second argument needs to be a function\n(maybe try using func_ease or perframe instead)'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_func_ease_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	local beat, len, eas, fn = self[1], self[2], self[3], self[#self]
	if type(beat) ~= 'number' then
		return 'the first argument needs to be a number in beats'
	end
	if type(len) ~= 'number' then
		return 'the second argument needs to be a number in beats'
	end
	if not is_valid_ease(eas) then
		return 'the third argument needs to be an ease'
	end
	if #self > 5 and type(self[4]) ~= 'number' then
		return 'the fourth argument needs to be a percentage'
	end
	if type(fn) ~= 'function' and type(fn) ~= 'string' then
		return 'the last argument needs to be a function to be eased'
	end
	if #self > 4 and type(self[#self - 1]) ~= 'number' then
		return 'the second-to-last argument needs to be a number'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_perframe_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	local beat, len, fn = self[1], self[2], self[3]
	if type(beat) ~= 'number' then
		return 'the first argument needs to be a number in beats'
	end
	if type(len) ~= 'number' then
		return 'the second argument needs to be a number in beats'
	end
	if type(fn) ~= 'function' and type(fn) ~= 'string' then
		return 'the third argument needs to be a function'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_alias_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	local a, b = self[1], self[2]
	if type(a) ~= 'string' then
		return 'argument 1 should be a string'
	end
	if type(b) ~= 'string' then
		return 'argument 2 should be a string'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_setdefault_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	for i = 1, #self, 2 do
		if type(self[i]) ~= 'number' then
			return 'invalid mod percent'
		end
		if type(self[i + 1]) ~= 'string' then
			return 'invalid mod name'
		end
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_aux_errrors(self, name)
	if type(self) ~= 'string' and type(self) ~= 'table' then
		return 'expecting curly braces'
	end
	if type(self) == 'table' then
		for _, v in ipairs(self) do
			if type(v) ~= 'string' then
				return 'invalid mod to aux: ' .. tostring(v)
			end
		end
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_node_errors(self, name)
	if type(self) ~= 'table' then
		return 'curly braces expected'
	end
	if type(self[2]) == 'number' then
		-- the shorthand version
		for i = 2, #self, 2 do
			if type(self[i]) ~= 'number' then
				return 'invalid mod percent'
			end
			if type(self[i + 1]) ~= 'string' then
				return 'invalid mod name'
			end
		end
	else
		-- the function form
		local i = 1
		while type(self[i]) == 'string' do
			i = i + 1
		end
		if i == 1 then
			return 'the first argument needs to be the mod name'
		end
		if type(self[i]) ~= 'function' then
			return 'mod definition expected'
		end
		i = i + 1
		while self[i] do
			if type(self[i]) ~= 'string' then
				return 'unexpected argument ' .. tostring(self[i]) .. ', expected a string'
			end
			i = i + 1
		end
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

-- ===================================================================== --

-- Main Functions

-- ease {start, len, eas, percent, 'mod'}
-- adds an ease to the ease table
function M.ease(self)
	-- Welcome to Ease!
	--
	-- -- Flags set by the user
	-- * plr: number[] or number or nil
	-- * mode: 'end' or nil (also m could be set to 'e')
	-- * time: true or nil
	--
	-- -- Flags set by the user (but only from `reset`)
	-- * only: mod[] or nil
	-- * exclude: mod[] or nil
	--
	-- -- Set by the other ease functions
	-- * relative: true or nil
	--     * makes this entry act like `add`
	-- * reset: true or nil
	--     * activates special reset code later
	--
	-- [1]: start beat (or time)
	-- [2]: length
	-- [3]: the ease
	-- [4 + 2*n]: the target mod value
	-- [5 + 2*n]: the mod name

	-- check for errors before processing inputs
	local err = check_ease_errors(self, 'ease')
	if err then
		error(err, 2)
	end

	-- convert mode into a regular true or false
	self.mode = self.mode == 'end' or self.m == 'e'

	-- convert the ease into relative
	if self.mode then
		self[2] = self[2] - self[1]
	end

	-- convert the start beat into time and store it in start_time
	self.start_time = self.time and self[1] or song:GetElapsedTimeFromBeat(self[1])

	-- future steps assume that plr is a number, so if it's a table,
	-- we need to duplicate the entry once for each player number
	-- The table is then stored into `eases` for later
	local plr = self.plr or get_plr()
	if type(plr) == 'table' then
		for i, pn in ipairs(plr) do
			local new = utils.copy(self)
			new.plr = pn
			table.insert(mirin.eases, new)
		end
	else
		self.plr = plr
		table.insert(mirin.eases, self)
	end
	return M.ease
end

-- add {start, len, eas, percent, mod}
-- adds an ease to the ease table
function M.add(self)
	local err = check_ease_errors(self, 'add')
	if err then
		error(err, 2)
	end
	self.relative = true
	M.ease(self)
	return M.add
end

-- set {start, percent, mod}
-- adds a set to the ease table
function M.set(self)
	local err = check_ease_errors(self, 'set')
	if err then
		error(err, 2)
	end
	table.insert(self, 2, 0)
	table.insert(self, 3, instant)
	M.ease(self)
	return M.set
end

-- acc {start, percent, mode}
-- adds a relative set to the ease table
function M.acc(self)
	local err = check_ease_errors(self, 'acc')
	if err then
		error(err, 2)
	end
	table.insert(self, 2, 0)
	table.insert(self, 3, instant)
	self.relative = true
	M.ease(self)
	return M.acc
end

-- reset {start, [len, eas], [exclude = {mod list}]}
-- adds a reset to the ease table
function M.reset(self)
	-- check for errors before processing inputs.
	local err = check_reset_errors(self, 'reset')
	if err then
		error(err, 2)
	end

	-- if a length and ease aren't provided, use `0, instant` to make it act like `set`
	self[2] = self[2] or 0
	self[3] = self[3] or instant

	-- set flag for the `run_eases` function to know that this is a reset entry
	self.reset = true

	if self.only then
		-- you can pass `only` to reset only a specific set of mods
		-- later code assumes this is a table if present, so here,
		-- single values need to get wrapped in a table.
		if type(self.only) == 'string' then
			self.only = { self.only }
		end
	elseif self.exclude then
		-- you can pass `exclude` to exclude a specific set of mods
		-- later code assumes this is a table if present, so here,
		-- single values need to get wrapped in a table.
		if type(self.exclude) == 'string' then
			self.exclude = { self.exclude }
		end

		-- When exclude is passed in, each mod is a value
		-- but it needs to become a table where each mod is a key
		local exclude = {}
		for i, v in ipairs(self.exclude) do
			exclude[v] = true
		end

		-- store it back
		self.exclude = exclude
	end

	-- just use ease to insert it into the ease table
	M.ease(self)
	return M.reset
end

do
	local compiled = {}
	-- func helper for scheduling a function
	function M.func(self)
		local err = check_func_errors(self, 'func')
		if err then
			error(err, 2)
		end

		-- func {5, 'P1:xy', 2, 3}
		if type(self[2]) == 'string' then
			local args, syms = {}, {}
			for i = 1, #self - 2 do
				syms[i] = 'arg' .. i
				args[i] = self[i + 2]
			end

			compiled[self[2]] = compiled[self[2]] or {}
			if not compiled[self[2]][#syms] then
				local symstring = table.concat(syms, ',')
				local code = stringbuilder.new()
				code('return function(')(symstring)(') return function()')(self[2])('(')(symstring)(') end end')
				compiled[self[2]][#syms] = xero(assert(loadstring(code:build(), 'func_generated')))()
			end

			self[2] = compiled[self[2]][#syms](unpack(args))
			while self[3] do
				table.remove(self)
			end
		end
		self[2], self[3] = nil, self[2]
		local persist = self.persist
		-- convert mode into a regular true or false
		self.mode = self.mode == 'end' or self.m == 'e'

		if type(persist) == 'number' and self.mode then
			persist = persist - self[1]
		end
		if persist == false then
			persist = 0.5
		end
		if type(persist) == 'number' then
			local fn = self[3]
			local final_time = self[1] + persist
			self[3] = function(beat)
				if beat < final_time then
					fn(beat)
				end
			end
		end

		self.priority = (self.defer and -1 or 1) * (#mirin.funcs + 1)
		self.start_time = self.time and self[1] or song:GetElapsedTimeFromBeat(self[1])

		table.insert(mirin.funcs, self)
		return M.func
	end
end

local disallowed_poptions_perframe_persist = setmetatable({}, {
	__index = function(_)
		error('you cannot use poptions and persist at the same time. </3')
	end,
})

-- func helper for scheduling a perframe
function M.perframe(self, deny_poptions)
	local err = check_perframe_errors(self, 'perframe')
	if err then
		error(err, 2)
	end

	-- convert into relative
	if self.mode then
		self[2] = self[2] - self[1]
	end
	if not deny_poptions then
		self.mods = {}
		for pn = 1, max_pn do
			self.mods[pn] = {}
		end
	end
	self.priority = (self.defer and -1 or 1) * (#mirin.funcs + 1)
	self.start_time = self.time and self[1] or song:GetElapsedTimeFromBeat(self[1])

	local persist = self.persist
	if persist then
		if type(persist) == 'number' and self.mode then
			persist = persist - self[1] - self[2]
		end
		M.func {
			self[1] + self[2],
			function()
				self[3](GAMESTATE:GetSongBeat(), disallowed_poptions_perframe_persist)
			end,
			persist = persist,
		}
	end

	table.insert(mirin.funcs, self)
	return M.perframe
end

-- func helper for function eases
do
	local compiled = {}
	function M.func_ease(self)
		local err = check_func_ease_errors(self, 'func_ease')
		if err then
			error(err, 2)
		end

		-- convert mode into a regular true or false
		self.mode = self.mode == 'end' or self.m == 'e'
		-- convert into relative
		if self.mode then
			self[2] = self[2] - self[1]
		end
		local fn = table.remove(self)
		local eas = self[3]
		local start_percent = #self >= 5 and table.remove(self, 4) or 0
		local end_percent = #self >= 4 and table.remove(self, 4) or 1
		local end_beat = self[1] + self[2]

		if type(fn) == 'string' then
			if not compiled[fn] then
				compiled[fn] = xero(assert(loadstring('return function(p)' .. fn .. '(p) end', 'func_generated')))()
			end
			fn = compiled[fn]
		end

		self[3] = function(beat)
			local progress = (beat - self[1]) / self[2]
			fn(start_percent + (end_percent - start_percent) * eas(progress))
		end

		-- it's a function-ease variant, so make it persist
		if self.persist ~= false then
			local final_percent = eas(1) > 0.5 and end_percent or start_percent
			M.func {
				end_beat,
				function()
					fn(final_percent)
				end,
				persist = self.persist,
				defer = self.defer,
			}
		end
		self.persist = false
		M.perframe(self, true)
		return M.func_ease
	end
end

-- alias {'old', 'new'}
-- aliases a mod
function M.alias(self)
	local err = check_alias_errors(self, 'alias')
	if err then
		error(err, 2)
	end
	local a, b = self[1], self[2]
	a, b = string.lower(a), string.lower(b)
	mirin.aliases[a] = b
	return M.alias
end

-- setdefault {percent, 'mod'}
-- set the default value of a mod
function M.setdefault(self)
	local err = check_setdefault_errors(self, 'setdefault')
	if err then
		error(err, 2)
	end
	for i = 1, #self, 2 do
		mirin.default_mods[self[i + 1]] = self[i]
	end
	return M.setdefault
end

-- aux {'mod'}
-- mark a mod as an aux, which won't get sent to `ApplyModifiers`
function M.aux(self)
	local err = check_aux_errrors(self, 'aux')
	if err then
		error(err, 2)
	end
	if type(self) == 'string' then
		local v = self
		mirin.auxes[v] = true
	elseif type(self) == 'table' then
		for i = 1, #self do
			M.aux(self[i])
		end
	end
	return M.aux
end

-- node {'inputs', function(inputs) return outputs end, 'outputs'}
-- create a listener that gets run whenever a mod value gets changed
function M.node(self)
	local err = check_node_errors(self, 'node')
	if err then
		error(err, 2)
	end
	if type(self[2]) == 'number' then
		-- transform the shorthand into the full version
		local multipliers = {}
		local i = 2
		while self[i] do
			local amt = string.format('p * %f', table.remove(self, i))
			table.insert(multipliers, amt)
			i = i + 1
		end
		local ret = table.concat(multipliers, ',')
		local code = 'return function(p) return ' .. ret .. ' end'
		local fn = loadstring(code, 'node_generated')()
		table.insert(self, 2, fn)
	end

	local i = 1
	local inputs = {}
	while type(self[i]) == 'string' do
		table.insert(inputs, self[i])
		i = i + 1
	end
	local fn = self[i]
	i = i + 1
	local outputs = {}
	while self[i] do
		table.insert(outputs, self[i])
		i = i + 1
	end
	local result = { inputs = inputs, outputs = outputs, fn = fn }
	result.priority = (self.defer and -1 or 1) * (#mirin.nodes + 1)
	table.insert(mirin.nodes, result)
	return M.node
end

-- definemod{'mod', function(mod, pn) end}
-- calls aux and node on the provided arguments
function M.definemod(self)
	local err = check_node_errors(self, 'definemod')
	if err then
		error(err, 2)
	end
	for i = 1, #self do
		if type(self[i]) ~= 'string' then
			break
		end
		M.aux(self[i])
	end
	M.node(self)
	return M.definemod
end

return M
