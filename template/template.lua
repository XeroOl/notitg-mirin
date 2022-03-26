-- Enable strict mode for this file
-- See template/std.xml for more details
setfenv(1, xero.strict)


-- ===================================================================== --

-- Convenience shortcuts / options

local max_pn = 8 -- default: `8`
local debug_print_applymodifier_input = false -- default: `false`
local debug_print_mod_targets = false -- default: `false`

local foreground = xero.foreground
local copy = xero.copy
local clear = xero.clear
local stringbuilder = xero.stringbuilder
local stable_sort = xero.stable_sort
local perframe_data_structure = xero.perframe_data_structure
local instant = xero.instant



-- ===================================================================== --

-- Data structures


-- the table of eases/add/set
local eases = {}

-- the table of scheduled functions and perframes
local funcs = {}

-- auxilliary variables
local auxes = {}

-- the table of nodes
local nodes = {}

-- mod aliases
local aliases = {}

-- mods whose values have changed that need to be applied
local touched_mods = {}
for pn = 1, max_pn do
	touched_mods[pn] = {}
end

-- store the default values for every mod
local default_mods = {}

-- the default_mods table defaults to 0
setmetatable(default_mods, {
	__index = function(self, i)
		self[i] = 0
		return 0
	end
})


local song = GAMESTATE:GetCurrentSong()


-- ===================================================================== --

-- Functions


-- the `plr=` system
local default_plr = {1, 2}

-- for reading the `plr` variable from the xero environment
-- without falling back to the global table
local function get_plr()
	return rawget(xero, 'plr') or default_plr
end

local banned_chars = {}
local _ = string.gsub('\'\\{}(),;* ', '.', function(t)
	banned_chars[t] = true
end)

local function normalize_mod_no_checks(name)
	name = string.lower(name)
	return aliases[name] or name
end

-- convert a mod to its lowercase dealiased name
local function normalize_mod(name)
	if banned_chars[string.sub(name, 1, 1)] or banned_chars[string.sub(name, #name, #name)] then
		error(
			'You have a typo in your mod name. '..
			'You wrote \''..name..'\', but you probably meant '..
			'\''..string.gsub(name, '[\'\\{}(),;* ]', '')..'\''
		)
	end
	return normalize_mod_no_checks(name)
end


-- ease {start, len, eas, percent, 'mod'}
-- adds an ease to the ease table
local function ease(self)

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
		for _, plr in ipairs(plr) do
			local new = copy(self)
			new.plr = plr
			table.insert(eases, new)
		end
	else
		self.plr = plr
		table.insert(eases, self)
	end

end

-- add {start, len, eas, percent, mod}
-- adds an ease to the ease table
local function add(self)
	self.relative = true
	ease(self)
end

-- set {start, percent, mod}
-- adds a set to the ease table
local function set(self)
	table.insert(self, 2, 0)
	table.insert(self, 3, instant)
	ease(self)
end


-- acc {start, percent, mod}
-- adds a relative set to the ease table
local function acc(self)
	self.relative = true
	table.insert(self, 2, 0)
	table.insert(self, 3, instant)
	ease(self)
end

-- reset {start, [len, eas], [exclude = {mod list}]}
-- adds a reset to the ease table
local function reset(self)
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
			self.only = {self.only}
		end
	elseif self.exclude then
		-- you can pass `exclude` to exclude a specific set of mods
		-- later code assumes this is a table if present, so here,
		-- single values need to get wrapped in a table.
		if type(self.exclude) == 'string' then
			self.exclude = {self.exclude}
		end

		-- When exclude is passed in, each mod is a value
		-- but it needs to become a table where each mod is a key
		local exclude = {}
		for _, v in ipairs(self.exclude) do
			exclude[v] = true
		end

		-- store it back
		self.exclude = exclude
	end

	-- just use ease to insert it into the ease table
	ease(self)
end

-- func helper for scheduling a function
local function func(self)
	-- func {5, 'P1:xy', 2, 3}
	if type(self[2]) == 'string' then
		local args, syms = {}, {}
		for i = 1, #self - 2 do
			syms[i] = 'arg' .. i
			args[i] = self[i + 2]
		end
		local symstring = table.concat(syms, ', ')
		local code = 'return function('..symstring..') return function() '..self[2]..'('..symstring..') end end'
		self[2] = xero(assert(loadstring(code, 'func_generated')))()(unpack(args))
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
	self.priority = (self.defer and -1 or 1) * (#funcs + 1)
	self.start_time = self.time and self[1] or song:GetElapsedTimeFromBeat(self[1])
	table.insert(funcs, self)
end

local disallowed_poptions_perframe_persist = setmetatable({}, {__index = function(_)
	error('you cannot use poptions and persist at the same time. </3')
end})

-- func helper for scheduling a perframe
local function perframe(self, deny_poptions)
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
	self.priority = (self.defer and -1 or 1) * (#funcs + 1)
	self.start_time = self.time and self[1] or song:GetElapsedTimeFromBeat(self[1])

	local persist = self.persist
	if persist then
		if type(persist) == 'number' and self.mode then
			persist = persist - self[1] - self[2]
		end
		func {
			self[1] + self[2],
			function()
				self[3](GAMESTATE:GetSongBeat(), disallowed_poptions_perframe_persist)
			end,
			persist = self.persist,
		}
	end

	table.insert(funcs, self)
end

-- func helper for function eases
local function func_ease(self)
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
		fn = xero(assert(loadstring('return function(p) '..fn..'(p) end', 'func_generated')))()
	end

	self[3] = function(beat)
		local progress = (beat - self[1]) / self[2]
		fn(start_percent + (end_percent - start_percent) * eas(progress))
	end

	-- it's a function-ease variant, so make it persist
	if self.persist ~= false then
		local final_percent = eas(1) > 0.5 and end_percent or start_percent
		func {
			end_beat,
			function()
				fn(final_percent)
			end,
			persist = self.persist,
			defer = self.defer,
		}
	end
	self.persist = false
	perframe(self, true)
end

-- alias {'old', 'new'}
-- aliases a mod
local function alias(self)
	local a, b = self[1], self[2]
	a, b = string.lower(a), string.lower(b)
	aliases[a] = b
end

-- setdefault {percent, 'mod'}
-- set the default value of a mod
local function setdefault(self)
	for i = 1, #self, 2 do
		default_mods[self[i + 1]] = self[i]
	end
	return setdefault
end

-- aux {'mod'}
-- mark a mod as an aux, which won't get sent to `ApplyModifiers`
local function aux(self)
	if type(self) == 'string' then
		local v = self
		auxes[v] = true
	elseif type(self) == 'table' then
		for i = 1, #self do
			aux(self[i])
		end
	end
	return aux
end

-- node {'inputs', function(inputs) return outputs end, 'outputs'}
-- create a listener that gets run whenever a mod value gets changed
local function node(self)

	if type(self[2]) == 'number' then
		-- transform the shorthand into the full version
		local multipliers = {}
		local i = 2
		while self[i] do
			local amt = string.format('p * %f', table.remove(self, i) * 0.01)
			table.insert(multipliers, amt)
			i = i + 1
		end
		local ret = table.concat(multipliers, ', ')
		local code = 'return function(p) return '..ret..' end'
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
	local out = {}
	while self[i] do
		table.insert(out, self[i])
		i = i + 1
	end
	local result = {inputs, out, fn}
	result.priority = (self.defer and -1 or 1) * (#nodes + 1)
	table.insert(nodes, result)
	return node
end

-- definemod{'mod', function(mod, pn) end}
-- calls aux and node on the provided arguments
local function definemod(self)
	for i = 1, #self do
		if type(self[i]) ~= 'string' then
			break
		end
		aux(self[i])
	end
	node(self)
	return definemod
end


-- ===================================================================== --

-- Runtime


-- mod targets are the values that the mod would be at if the current eases finished
local targets = {}
local targets_mt = {__index = default_mods}
for pn = 1, max_pn do
	targets[pn] = setmetatable({}, targets_mt)
end

-- the live value of the current mods. Gets recomputed each frame
local mods = {}
local mods_mt = {}
for pn = 1, max_pn do
	mods_mt[pn] = {__index = targets[pn]}
	mods[pn] = setmetatable({}, mods_mt[pn])
end

-- a stringbuilder of the modstring that is being applied
local mod_buffer = {}
for pn = 1, max_pn do
	mod_buffer[pn] = stringbuilder()
end

-- data structure for nodes
local node_start = {}

-- keep track of which players are awake
local last_seen_awake = {}

-- poptions table
local poptions = {}
local poptions_logging_target
for pn = 1, max_pn do
	local pn = pn
	local mods_pn = mods[pn]
	local mt = {
		__index = function(_, k)
			return mods_pn[normalize_mod_no_checks(k)]
		end,
		__newindex = function(_, k, v)
			k = normalize_mod_no_checks(k)
			mods_pn[k] = v
			if v then
				poptions_logging_target[pn][k] = true
			end
		end,
	}
	poptions[pn] = setmetatable({}, mt)
end

local function touch_mod(mod, pn)
	-- run metatables to ensure that the mod gets applied this frame
	if pn then
		mods[pn][mod] = mods[pn][mod]
	else
		-- if no player is provided, run for every player
		for pn = 1, max_pn do
			touch_mod(mod, pn)
		end
	end
end

local function touch_all_mods(pn)
	for mod in pairs(default_mods) do
		touch_mod(mod)
	end
	if pn then
		for mod in pairs(targets[pn]) do
			touch_mod(mod, pn)
		end
	else
		for pn = 1, max_pn do
			for mod in pairs(targets[pn]) do
				touch_mod(mod, pn)
			end
		end
	end
end

-- runs once during OnCommand
-- takes Name= actors and places them in the xero table
local function scan_named_actors()
	local mt = {}
	function mt.__index(self, k)
		self[k] = setmetatable({}, mt)
		return self[k]
	end
	local actors = setmetatable({}, mt)
	local list = {}
	local code = stringbuilder()
	local function sweep(actor, skip)
		if actor.GetNumChildren then
			for i = 0, actor:GetNumChildren() - 1 do
				sweep(actor:GetChildAt(i))
			end
		end
		if skip then
			return
		end
		local name = actor:GetName()
		if name and name ~= '' then
			if loadstring('t.'..name..'=t') then
				table.insert(list, actor)
				code'actors.'(name)' = list['(#list)']\n'
			else
				SCREENMAN:SystemMessage('invalid actor name: \''..name..'\'')
			end
		end
	end

	code'return function(list, actors)\n'
	sweep(foreground, true)
	code'end'

	local load_actors = xero(assert(loadstring(code:build())))()
	load_actors(list, actors)

	local function clear_metatables(tab)
		setmetatable(tab, nil)
		for _, obj in pairs(tab) do
			if type(obj) == 'table' and getmetatable(obj) == mt then
				clear_metatables(obj)
			end
		end
	end
	clear_metatables(actors)

	for name, actor in pairs(actors) do
		xero[name] = actor
	end

end

local function on_command(self)
	scan_named_actors()
	self:queuecommand('Ready')
end

-- runs once during ScreenReadyCommand, before the user code is loaded
-- hides various actors that are placed by the theme
local function hide_theme_actors()
	for _, element in ipairs {
		'Overlay', 'Underlay',
		'ScoreP1', 'ScoreP2',
		'LifeP1', 'LifeP2',
	} do
		local child = SCREENMAN(element)
		if child then child:hidden(1) end
	end
end

-- runs once during ScreenReadyCommand, before the user code is loaded
-- sets up the player tables
local P = {}
local function prepare_variables()
	for pn = 1, max_pn do
		local player = SCREENMAN('PlayerP' .. pn)
		xero['P' .. pn] = player
		P[pn] = player
	end
	xero.P = P
end

-- runs once during ScreenReadyCommand, after the user code is loaded
-- sorts the mod tables so that things can be processed in order
-- after the mod tables are sorted, no more calls to table-inserting functions are allowed
local function sort_tables()
	-- sort eases by their start time, with resets running first if there's a tie break
	-- it's a stable sort, so other ties are broken based on insertion order
	stable_sort(eases, function(a, b)
		if a.start_time == b.start_time then
			return a.reset and not b.reset
		else
			return a.start_time < b.start_time
		end
	end)

	-- sort the funcs by their start time and priority
	-- the priority matches the insertion order unless the user added `defer = true`,
	-- in which case the priority will be negative
	stable_sort(funcs, function(a, b)
		if a.start_time == b.start_time then
			local x, y = a.priority, b.priority
			return x * x * y < x * y * y
		else
			return a.start_time < b.start_time
		end
	end)

	-- sort the nodes by their priority
	-- the priority matches the insertion order unless the user added `defer = true`,
	-- in which case the priority will be negative
	stable_sort(nodes, function(a, b)
		local x, y = a.priority, b.priority
		return x * x * y < x * y * y
	end)
end

-- runs once during ScreenReadyCommand, after the user code is loaded
-- replaces aliases with their respective mods
local function resolve_aliases()
	-- ease
	for _, e in ipairs(eases) do
		for i = 5, #e, 2 do
			e[i] = normalize_mod(e[i])
		end
		if e.exclude then
			local exclude = {}
			for k, v in pairs(e.exclude) do
				exclude[normalize_mod(k)] = v
			end
			e.exclude = exclude
		end
		if e.only then
			for i = 1, #e.only do
				e.only[i] = normalize_mod(e.only[i])
			end
		end
	end
	-- aux
	local old_auxes = copy(auxes)
	clear(auxes)
	for mod, _ in pairs(old_auxes) do
		auxes[normalize_mod(mod)] = true
	end
	-- node
	for _, node_entry in ipairs(nodes) do
		local input = node_entry[1]
		local output = node_entry[2]
		for i = 1, #input do input[i] = normalize_mod(input[i]) end
		for i = 1, #output do output[i] = normalize_mod(output[i]) end
	end
	-- default_mods
	local old_default_mods = copy(default_mods)
	clear(default_mods)
	for mod, percent in pairs(old_default_mods) do
		local normalized = normalize_mod(mod)
		default_mods[normalized] = percent
		for pn = 1, max_pn do
			touched_mods[pn][normalized] = true
		end
	end
end

-- runs once during ScreenReadyCommand
local function compile_nodes()
	local terminators = {}
	for _, nd in ipairs(nodes) do
		for _, mod in ipairs(nd[2]) do
			terminators[mod] = true
		end
	end
	local priority = -1 * (#nodes + 1)
	for k, _ in pairs(terminators) do
		table.insert(nodes, {{k}, {}, nil, nil, nil, nil, nil, true, priority = priority})
	end
	local start = node_start
	local locked = {}
	local last = {}
	for _, nd in ipairs(nodes) do
		-- struct node {
		--     list<string> inputs;
		--     list<string> out;
		--     lua_function fn;
		--     list<struct node> children;
		--     list<list<struct node>> parents; // the inner lists also have a [0] field that is a boolean
		--     lua_function real_fn;
		--     list<map<string, float>> outputs;
		--     bool terminator;
		--     int seen;
		-- }
		local terminator = nd[8]
		if not terminator then
			nd[4] = {} -- children
			nd[7] = {} -- outputs
			for pn = 1, max_pn do
				nd[7][pn] = {}
			end
		end
		nd[5] = {} -- parents
		local inputs = nd[1]
		local out = nd[2]
		local fn = nd[3]
		local parents = nd[5]
		local outputs = nd[7]
		local reverse_in = {}
		for i, v in ipairs(inputs) do
			reverse_in[v] = true
			start[v] = start[v] or {}
			parents[i] = {}
			if not start[v][locked] then
				table.insert(start[v], nd)
			end
			if start[v][locked] then
				parents[i][0] = true
			end
			for _, pre in ipairs(last[v] or {}) do
				table.insert(pre[4], nd)
				table.insert(parents[i], pre[7])
			end
		end
		for _, v in ipairs(out) do
			if reverse_in[v] then
				start[v][locked] = true
				last[v] = {nd}
			elseif not last[v] then
				last[v] = {nd}
			else
				table.insert(last[v], nd)
			end
		end

		local function escapestr(s)
			return '\'' .. string.gsub(s, '[\\\']', '\\%1') .. '\''
		end
		local function list(code, i, sep)
			if i ~= 1 then code(sep) end
		end

		local code = stringbuilder()
		local function emit_inputs()
			for i, mod in ipairs(inputs) do
				list(code, i, ',')
				for j = 1, #parents[i] do
					list(code, j, '+')
					code'parents['(i)']['(j)'][pn]['(escapestr(mod))']'
				end
				if not parents[i][0] then
					list(code, #parents[i] + 1, '+')
					code'mods[pn]['(escapestr(mod))']'
				end
			end
		end
		local function emit_outputs()
			for i, mod in ipairs(out) do
				list(code, i, ',')
				code'outputs[pn]['(escapestr(mod))']'
			end
			return out[1]
		end
		code
		'return function(outputs, parents, mods, fn)\n'
			'return function(pn)\n'
				if terminator then
					code'mods[pn]['(escapestr(inputs[1]))'] = ' emit_inputs() code'\n'
				else
					if emit_outputs() then code' = ' end code 'fn(' emit_inputs() code', pn)\n'
				end
				code
			'end\n'
		'end\n'

		local compiled = assert(loadstring(code:build(), 'node_generated'))()
		nd[6] = compiled(outputs, parents, mods, fn)
		if not terminator then
			for pn = 1, max_pn do
				nd[6](pn)
			end
		end
	end

	for mod, v in pairs(start) do
		v[locked] = nil
	end
end

local function apply_modifiers(str, pn)
	GAMESTATE:ApplyModifiers(str, pn)
end

-- this if statement won't run unless you are mirin
if debug_print_applymodifier_input then
	-- luacov: disable
	local old_apply_modifiers = apply_modifiers
	apply_modifiers = function(str, pn)
		if debug_print_applymodifier_input == true or debug_print_applymodifier_input < GAMESTATE:GetSongBeat() then
			print('PLAYER ' .. pn .. ': ' .. str)
			if debug_print_applymodifier_input ~= true then
				apply_modifiers = old_apply_modifiers
			end
		end
		old_apply_modifiers(str, pn)
	end
	-- luacov: enable
end

local eases_index = 1
local active_eases = {}

local function run_eases(beat, time)
	-- {start_beat, len, ease, p0, m0, p1, m1, p2, m2, p3, m3}
	-- `eases` is the full sorted timeline of every ease
	-- `eases_index` is pointing to the next ease in the timeline that hasn't started yet
	while eases_index <= #eases do
		local e = eases[eases_index]
		-- measure by beat by default, or time if time=true was set
		local measure = e.time and time or beat
		-- if it's not ready, break out of the loop
		-- the eases table is sorted, so none of the later eases will be done either
		if measure < e[1] then break end

		-- At this point, we've already decided we need to add the ease to the active_eases table
		-- The next step is to prepare the entry to go into the `active_eases` table
		-- The problem is that the `active_eases` code makes a bunch of assumptions (so it can run faster), so
		-- the ease entry needs to be normalized.
		-- A "normalized" ease is basically of the form:
		--     {beat, len, ease, offset1, mod1, offset2, mod2, ...}
		--
		-- Here are some important things that need to be made true for an active ease:
		-- * It always lists out all mods being affected
		--     * even a 'reset' one
		-- * It always has relative numbers for its mods
		--     * this makes the logic just work when there's more than one ease touching the same mod
		-- * It is relative to the end point, not the start point.
		--     * This one is kind of complicated.
		--       the ease "commits" its changes to the targets table instantly
		--       and the display value only lags behind visually.

		-- plr is just a number at this point, because of the code in `ease`
		local plr = e.plr

		-- special cases for reset
		if e.reset then
			if e.only then
				-- Reset only these mods, because only= was set.
				for _, mod in ipairs(e.only) do
					table.insert(e, default_mods[mod])
					table.insert(e, mod)
				end
			else
				-- Reset any mod that isn't excluded and isn't at its default value.
				-- The goal is to normalize the reset into a regular ease entry
				-- by just inserting the default values.
				for mod in pairs(targets[plr]) do
					if not(e.exclude and e.exclude[mod]) and targets[plr][mod] ~= default_mods[mod] then
						table.insert(e, default_mods[mod])
						table.insert(e, mod)
					end
				end
			end
		end

		-- If it isn't using relative already, it needs to be adjusted to be relative (ie, like 'add', not like 'ease')
		-- Adjusted based on what the current target is set to
		-- This is the reason why the sorting the eases table needs to be stable.
		if not e.relative then
			for i = 4, #e, 2 do
				local mod = e[i + 1]
				e[i] = e[i] - targets[plr][mod]
			end
		end

		e.offset = 0
		-- If the ease value ends with 0.5 or more, the ease should "stick".
		-- Ie, if you use outExpo, the value should stay on until turned off.
		-- this is a poor quality comment
		if e[3](1) >= 0.5 then
			e.offset = 1
			for i = 4, #e, 2 do
				local mod = e[i + 1]
				targets[plr][mod] = targets[plr][mod] + e[i]
			end
		end
		-- activate the ease and move to the next one
		table.insert(active_eases, e)
		eases_index = eases_index + 1
	end

	-- Every ease that's active needs to be animated
	local active_eases_index = 1
	while active_eases_index <= #active_eases do
		local e = active_eases[active_eases_index]
		local plr = e.plr
		local measure = e.time and time or beat
		if measure < e[1] + e[2] then
			-- For every active ease, calculate the current magnitude of the ease
			local e3 = e[3]((measure - e[1]) / e[2]) - e.offset
			-- Go through all of the mods in the ease and write the temporary changes
			-- to the mods table.
			for i = 4, #e, 2 do
				local mod = e[i + 1]
				mods[plr][mod] = mods[plr][mod] + e3 * e[i]
			end
			active_eases_index = active_eases_index + 1
		else
			-- If the ease is done, the change to the targets table has already been made
			-- so the ease only needs to be removed from the active_eases table.
			-- First, we mark the mods as touched, so that eases with length 0
			-- will still apply, even while being active for 0 frames.
			for i = 4, #e, 2 do
				local mod = e[i + 1]
				touch_mod(mod, plr)
			end
			-- Then, the ease needs to be tossed out.
			if active_eases_index ~= #active_eases then
				-- Since the order of the active eases table doesn't matter,
				-- we can remove an item by moving the last item to the current index.
				-- For example, turning the list [1, 2, 3, 4, 5] into [1, 5, 3, 4] removes item 2
				-- This strategy is used because it's faster than calling table.remove with an index
				active_eases[active_eases_index] = table.remove(active_eases)
			else
				-- If it's already at the end of the list, just remove the item with table.remove.
				table.remove(active_eases)
			end
		end
	end
end

local funcs_index = 1
local active_funcs = perframe_data_structure(function(a, b)
	local x, y = a.priority, b.priority
	return x * x * y < x * y * y
end)
local function run_funcs(beat, time)
	while funcs_index <= #funcs do
		local e = funcs[funcs_index]
		local measure = e.time and time or beat
		if measure < e[1] then break end
		if not e[2] then
			e[3](measure)
		elseif measure < e[1] + e[2] then
			active_funcs:add(e)
		end
		funcs_index = funcs_index + 1
	end

	while true do
		local e = active_funcs:next()
		if not e then break end
		local measure = e.time and time or beat
		if measure < e[1] + e[2] then
			poptions_logging_target = e.mods
			e[3](measure, poptions)
		else
			if e.mods then
				for pn = 1, max_pn do
					for mod, _ in pairs(e.mods[pn]) do
						touch_mod(mod, pn)
					end
				end
			end
			active_funcs:remove()
		end
	end

end

local seen = 1
local active_nodes = {}
local active_terminators = {}
local propagateAll, propagate
function propagateAll(nodes_to_propagate)
	if nodes_to_propagate then
		for _, nd in ipairs(nodes_to_propagate) do
			propagate(nd)
		end
	end
end
function propagate(nd)
	if nd[9] ~= seen then
		nd[9] = seen
		if nd[8] then
			table.insert(active_terminators, nd)
		else
			propagateAll(nd[4])
			table.insert(active_nodes, nd)
		end
	end
end

local function run_nodes()
	for pn = 1, max_pn do
		if P[pn] and P[pn]:IsAwake() then
			if not last_seen_awake[pn] then
				last_seen_awake[pn] = true
				for mod, _ in pairs(touched_mods[pn]) do
					touch_mod(mod, pn)
					touched_mods[pn][mod] = nil
				end
			end
			seen = seen + 1
			for k in pairs(mods[pn]) do
				-- identify all nodes to execute this frame
				propagateAll(node_start[k])
			end
			for _ = 1, #active_nodes do
				-- run all the nodes
				table.remove(active_nodes)[6](pn)
			end
			for _ = 1, #active_terminators do
				-- run all the nodes marked as 'terminator'
				table.remove(active_terminators)[6](pn)
			end
		else
			last_seen_awake[pn] = false
			for mod, _ in pairs(mods[pn]) do
				mods[pn][mod] = nil
				touched_mods[pn][mod] = true
			end
		end
	end
end

local function run_mods()
	-- each player is processed separately
	for pn = 1, max_pn do
		-- if the player is active
		if P[pn] and P[pn]:IsAwake() then
			local buffer = mod_buffer[pn]
			-- toss everything that isn't an aux into the buffer
			for mod, percent in pairs(mods[pn]) do
				if not auxes[mod] then
					buffer('*-1 '..percent..' '..mod)
				end
				mods[pn][mod] = nil
			end
			-- if the buffer has at least 1 item in it
			-- then pass it to ApplyModifiers
			if buffer[1] then
				apply_modifiers(buffer:build(','), pn)
				buffer:clear()
			end
		end
	end
end

-- this if statement won't run unless you are mirin
if debug_print_mod_targets then
	-- luacov: disable
	func {0, 9e9, function(beat)
		if debug_print_mod_targets == true or debug_print_mod_targets < beat then
			for pn = 1, max_pn do
				if P[pn] and P[pn]:IsAwake() then
					local outputs = {}
					local i = 0
					for k, v in pairs(targets[pn]) do
						if v ~= default_mods[k] then
							i = i + 1
							outputs[i] = tostring(k)..': '..tostring(v)
						end
					end
					print('Player '..pn..' at beat '..beat..' --> '..table.concat(outputs, ', '))
				else
					print('Player '..pn..' is asleep or missing')
				end
			end
			debug_print_mod_targets = (debug_print_mod_targets == true)
		end
	end}
	-- luacov: enable
end

local is_beyond_load_command = false

local function ready_command(self)
	hide_theme_actors()
	prepare_variables()
	foreground:hidden(0)

	-- loads both the plugins and the layout.xml due to propagation
	foreground:playcommand('Load')
	-- loads mods.lua
	xero.require 'mods'

	sort_tables()
	resolve_aliases()
	compile_nodes()

	for i = 1, max_pn do
		mod_buffer[i]:clear()
	end

	-- load command has happened
	-- Set this variable so that ease{}s get denied past this point
	is_beyond_load_command = true

	-- make sure nodes are up to date
	run_nodes()
	run_mods()

	self:luaeffect('Update')
end

local function update_command(self)
	self:hidden(1)

	local beat = GAMESTATE:GetSongBeat()
	local time = self:GetSecsIntoEffect()

	run_eases(beat, time)
	run_funcs(beat, time)
	run_nodes()
	run_mods()

	-- if no errors have occurred, unhide self
	-- to make the update_command run again next frame
	self:hidden(0)
end

---------------------------------------------------------------------------------------
GAMESTATE:ApplyModifiers('clearall')


-- zoom
aux 'zoom'
node {
	'zoom', 'zoomx', 'zoomy',
	function(zoom, x, y)
		local m = zoom * 0.01
		return m * x, m * y
	end,
	'zoomx', 'zoomy',
	defer = true,
}

setdefault {
	100, 'zoom',
	100, 'zoomx',
	100, 'zoomy',
	100, 'zoomz',
}

setdefault {400, 'grain'}

-- movex
local function repeat8(a)
	return a, a, a, a, a, a, a, a
end

for _, a in ipairs {'x', 'y', 'z'} do
	definemod {
		'move' .. a,
		repeat8,
		'move'..a..'0', 'move'..a..'1', 'move'..a..'2', 'move'..a..'3',
		'move'..a..'4', 'move'..a..'5', 'move'..a..'6', 'move'..a..'7',
		defer = true,
	}
end

-- xmod
setdefault {1, 'xmod'}
definemod {
	'xmod', 'cmod',
	function(xmod, cmod, pn)
		if cmod == 0 then
			mod_buffer[pn](string.format('*-1 %fx', xmod))
		else
			mod_buffer[pn](string.format('*-1 %fx,*-1 c%f', xmod, cmod))
		end
	end,
	defer = true,
}


-- ===================================================================== --

-- Error checking


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
	assert(self[i + 1] == nil, 'invalid mod percent: '..tostring(self[i]))
	local plr = self.plr or get_plr()
	if type(plr) ~= 'number' and type(plr) ~= 'table' then
		return 'invalid plr'
	end
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
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
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
	end
end

local valid_func_signatures = {
	['number, function'] = true,
	['number, number, function'] = true,
	['number, number, ease, function'] = true,
	['number, number, ease, string'] = true,
	['number, number, ease, number, function'] = true,
	['number, number, ease, number, string'] = true,
	['number, number, ease, number, number, function'] = true,
	['number, number, ease, number, number, string'] = true,
	['number, string, ?'] = true,
}

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
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
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
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
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
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
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
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
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
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
	end
end

local function check_aux_errrors(self, name)
	if type(self) ~= 'string' and type(self) ~= 'table' then
		return 'expecting curly braces'
	end
	if type(self) == 'table' then
		for _, v in ipairs(self) do
			if type(v) ~= 'string' then
				return 'invalid mod to aux: '.. tostring(v)
			end
		end
	end
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
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
				return 'unexpected argument '..tostring(self[i])..', expected a string'
			end
			i = i + 1
		end
	end
	if is_beyond_load_command then
		return 'cannot call '..name..' after LoadCommand finished'
	end
end


-- ===================================================================== --

-- Exports


local function export(fn, check_errors, name)
	local function inner(self)
		local err = check_errors(self, name)
		if err then
			error(name..': '..err, 2)
		else
			fn(self)
		end
		return inner
	end
	xero[name] = inner
end

export(ease, check_ease_errors, 'ease')
export(add, check_ease_errors, 'add')
export(set, check_ease_errors, 'set')
export(acc, check_ease_errors, 'acc')
export(reset, check_reset_errors, 'reset')
export(func, check_func_errors, 'func')
export(perframe, check_perframe_errors, 'perframe')
export(func_ease, check_func_ease_errors, 'func_ease')
export(alias, check_alias_errors, 'alias')
export(setdefault, check_setdefault_errors, 'setdefault')
export(aux, check_aux_errrors, 'aux')
export(node, check_node_errors, 'node')
export(definemod, check_node_errors, 'definemod')
xero.get_plr = get_plr
xero.touch_mod = touch_mod
xero.touch_all_mods = touch_all_mods

xero.max_pn = max_pn


xero()

scx = SCREEN_CENTER_X
scy = SCREEN_CENTER_Y
sw = SCREEN_WIDTH
sh = SCREEN_HEIGHT

dw = DISPLAY:GetDisplayWidth()
dh = DISPLAY:GetDisplayHeight()

e = 'end'

function sprite(self)
	self:basezoomx(sw / dw)
	self:basezoomy(-sh / dh)
	self:x(scx)
	self:y(scy)
end

function aft(self)
	self:SetWidth(dw)
	self:SetHeight(dh)
	self:EnableDepthBuffer(false)
	self:EnableAlphaBuffer(false)
	self:EnableFloat(false)
	self:EnablePreserveTexture(true)
	self:Create()
end


function setupJudgeProxy(proxy, target, pn)
	proxy:SetTarget(target)
	proxy:xy(scx * (pn-.5), scy)
	target:hidden(1)
	target:sleep(9e9)
end

function backToSongWheel(message)
	if message then
		SCREENMAN:SystemMessage(message)
		print(message)
	end
	GAMESTATE:FinishSong()
	-- disable update_command
	foreground:hidden(1)
end

-- UNDOCUMENTED
xero.mod_buffer = mod_buffer

---@diagnostic disable-next-line: lowercase-global
function xero.aftsprite(aft, sprite)
	sprite:SetTexture(aft:GetTexture())
end

-- end UNDOCUMENTED

-- This is the entry point of the template.
-- It sets up all of the commands used to run the template.
function xero.init_command(self)
	-- This sets up a trick to get the Song time during the update command
	self:effectclock('music')

	-- Register the commands to the actor

	-- OnCommand is for resolving Name= on all the actors
	self:addcommand('On', on_command)

	-- ReadyCommand is called after OnCommand, and does all of the loading
	-- at the end of ReadyCommand, the tables are sorted and prepared for UpdateCommand
	self:addcommand('Ready', ready_command)

	-- Update command is called every frame. It is what sets the mod values every frame,
	-- and reads through everything that's been queued by the user.
	-- Delay one frame because the escape menu issue
	self:addcommand('Update', function()
		self:removecommand('Update')
		self:addcommand('Update', update_command)
	end)

	-- NotITG and OpenITG have a long standing bug where the InitCommand on an actor can run twice in certain cases.
	-- By removing the command here (at the end of init_command), we prevent it from being run again.
	self:removecommand('Init')

	-- init_command is the only one that was in the xero table, so clean it up
	xero.init_command = nil
end
