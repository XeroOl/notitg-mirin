local options = require('core.options')
local utils = require('core.utils')
local sort = require('core.utils.sort')
local stringbuilder = require('core.utils.stringbuilder')
local perframedatastructure = require('core.utils.perframedatastructure')

local foreground = xero.foreground
local max_pn = options.max_pn
local debug_print_mod_targets = options.debug_print_mod_targets
local debug_print_applymodifier_input = options.debug_print_applymodifier_input

local M = {}

-- eases :: list of {beat/time, len, ease_, *args, pn = number, start_time = number}
--                     and a couple of other optional string keys
-- table for eases/add/set/acc/reset
--
-- pn must be present, and must be a number.
-- start_time must be present, and is the time that the effect starts *in seconds*
--
-- Before readycommand is run:
-- * Is in the order that the mods have been inserted
-- * You can insert into this table
-- After readycommand is run:
-- * is sorted by start_time with insertion order as tiebreaker
-- * ease/add/set/acc should not insert anymore, because it will ruin the sort order.
local eases = {}
M.eases = eases

-- funcs :: list of {beat, len?, fn}, and a couple of other optional string keys
-- the table of scheduled functions and perframes
--
-- if the len is present, it will be treated as a perframe, otherwise a func.
-- This table will be loaded by other modules.
local funcs = {}
M.funcs = funcs

-- auxes :: table where auxes[modname] = true when modname is auxed
-- auxilliary variables
--
-- when a mod is "auxed", it won't be applied via ApplyModifiers to the game.
-- This usually means that the mod has an in-template implementation in lua.
-- When a mod isn't auxed, it will be handled by the c++ game engine source code.
local auxes = {}
M.auxes = auxes

-- aliases :: table where aliases[old] = new
-- mods that should be renamed.
--
-- The replacement happens in the resolve_aliases function.
-- This table is stored in lowercase.
local aliases = {}
M.aliases = aliases

-- nodes :: list of {list<string> inputs, function(inputs) -> outputs, list<string> outputs}
-- stores nodes / definemods
--
-- After the nodes are compiled, it changes format to something different.
local nodes = {}
M.nodes = nodes

-- touched_mods :: table where touched_mods[pn][mod] = true
-- mods whose values have changed that need to be applied
local touched_mods = {}
for pn = 1, max_pn do
	touched_mods[pn] = {}
end

-- default_mods :: table where default_mods[mod] = number
-- store the default values for every mod
local default_mods = {}
M.default_mods = default_mods

-- use metatables to prefill the default_mods table with 0
setmetatable(default_mods, {
	__index = function(self, i)
		self[i] = 0
		return 0
	end,
})

local banned_chars = {}
local banned_chars_string = "'\\{}(),;* "
for i = 1, #banned_chars_string do
	banned_chars[string.sub(banned_chars_string, i, i)] = true
end

-- A mod name isn't valid if it would cause problems when put into
-- the "*-1 100 {}" format that GAMESTATE:ApplyModifiers expects.
-- For example, the space in 'invert ' means the game engine would treat
-- it identically to regular 'invert', which is why 'invert ' should be denied.
local function ensure_mod_name_is_valid(name)
	if banned_chars[string.sub(name, 1, 1)] or banned_chars[string.sub(name, -1, -1)] then
		error(
			'You have a typo in your mod name. '
				.. "You wrote '"
				.. name
				.. "', but you probably meant '"
				.. string.gsub(name, "['\\{}(),;* ]", '')
				.. "'"
		)
	end
	if string.find(name, '^c[0-9]+$') then
		error("You can't name your mod '" .. name .. "'.\n" .. "Use 'cmod' if you want to set a cmod.")
	end
	if string.find(name, '^[0-9.]+x$') then
		error("You can't name your mod '" .. name .. "'.\n" .. "Use 'xmod' if you want to set an xmod.")
	end
end

function M.normalize_mod_no_checks(name)
	name = string.lower(name)
	return aliases[name] or name
end

-- convert a mod to its lowercase dealiased name
function M.normalize_mod(name)
	if not auxes[name] then
		ensure_mod_name_is_valid(name)
	end
	return M.normalize_mod_no_checks(name)
end

-- Runtime

-- mod targets are the values that the mod would be at if the current eases finished
local targets = {}
local targets_mt = { __index = default_mods }
for pn = 1, max_pn do
	targets[pn] = setmetatable({}, targets_mt)
end

-- the live value of the current mods. Gets recomputed each frame
local mods = {}
local mods_mt = {}
for pn = 1, max_pn do
	mods_mt[pn] = { __index = targets[pn] }
	mods[pn] = setmetatable({}, mods_mt[pn])
end

-- a stringbuilder of the modstring that is being applied
local mod_buffer = {}
for pn = 1, max_pn do
	mod_buffer[pn] = {}
end
M.mod_buffer = mod_buffer

-- poptions table
local poptions = {}
local poptions_logging_target
for pn = 1, max_pn do
	local pn = pn
	local mods_pn = mods[pn]
	local mt = {
		__index = function(_, k)
			return mods_pn[M.normalize_mod_no_checks(k)]
		end,
		__newindex = function(_, k, v)
			k = M.normalize_mod_no_checks(k)
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
		for each_pn = 1, max_pn do
			touch_mod(mod, each_pn)
		end
	end
end
M.touch_mod = touch_mod

function M.touch_all_mods(pn)
	for mod in pairs(default_mods) do
		touch_mod(mod)
	end
	if pn then
		for mod in pairs(targets[pn]) do
			touch_mod(mod, pn)
		end
	else
		for each_pn = 1, max_pn do
			for mod in pairs(targets[each_pn]) do
				touch_mod(mod, each_pn)
			end
		end
	end
end

local function sweep(actors, actor)
	local name = actor:GetName()
	if name and name ~= '' then
		if loadstring('t.' .. name .. '=t') then
			loadstring('return function(actors, actor) actors.' .. name .. ' = actor end')()(actors, actor)
		else
			SCREENMAN:SystemMessage("invalid actor name: '" .. name .. "'")
		end
	end
	if actor.GetNumChildren then
		for i = 0, actor:GetNumChildren() - 1 do
			sweep(actors, actor:GetChildAt(i))
		end
	end
end

local viral_mt = {}
function viral_mt.__index(self, k)
	self[k] = setmetatable({}, viral_mt)
	return self[k]
end

local function clear_viral_metatables(tab)
	setmetatable(tab, nil)
	for _, obj in pairs(tab) do
		if type(obj) == 'table' and getmetatable(obj) == viral_mt then
			clear_viral_metatables(obj)
		end
	end
end

-- runs once during OnCommand
-- takes Name= actors and places them in the xero table
function M.scan_named_actors()
	local actors = setmetatable({}, viral_mt)

	sweep(actors, foreground)
	clear_viral_metatables(actors)

	-- expose the list of actors as a package
	package.loaded['mirin.actors'] = actors
end

-- runs once during ScreenReadyCommand, before the user code is loaded
-- sets up the player tables
local P = {}
M.P = P
function M.prepare_variables()
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
function M.sort_tables()
	-- sort eases by their start time, with resets running first if there's a tie break
	-- it's a stable sort, so other ties are broken based on insertion order
	sort.stable_sort(eases, function(a, b)
		if a.start_time == b.start_time then
			return a.reset and not b.reset
		else
			return a.start_time < b.start_time
		end
	end)

	-- sort the funcs by their start time and priority
	-- the priority matches the insertion order unless the user added `defer = true`,
	-- in which case the priority will be negative
	sort.stable_sort(funcs, function(a, b)
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
	sort.stable_sort(nodes, function(a, b)
		local x, y = a.priority, b.priority
		return x * x * y < x * y * y
	end)
end

-- runs once during ScreenReadyCommand, after the user code is loaded
-- replaces aliases with their respective mods
function M.resolve_aliases()
	-- aux
	local old_auxes = utils.copy(auxes)
	utils.clear(auxes)
	for mod, _ in pairs(old_auxes) do
		-- auxes bypass name checks
		auxes[M.normalize_mod_no_checks(mod)] = true
	end
	-- ease
	for _, e in ipairs(eases) do
		for i = 5, #e, 2 do
			e[i] = M.normalize_mod(e[i])
		end
		if e.exclude then
			local exclude = {}
			for k, v in pairs(e.exclude) do
				exclude[M.normalize_mod(k)] = v
			end
			e.exclude = exclude
		end
		if e.only then
			for i = 1, #e.only do
				e.only[i] = M.normalize_mod(e.only[i])
			end
		end
	end
	-- node
	for _, node_entry in ipairs(nodes) do
		local input = node_entry[1]
		local output = node_entry[2]
		for i = 1, #input do
			input[i] = M.normalize_mod(input[i])
		end
		for i = 1, #output do
			output[i] = M.normalize_mod(output[i])
		end
	end
	-- default_mods
	local old_default_mods = utils.copy(default_mods)
	utils.clear(default_mods)
	for mod, percent in pairs(old_default_mods) do
		local normalized = M.normalize_mod(mod)
		default_mods[normalized] = percent
		for pn = 1, max_pn do
			touched_mods[pn][normalized] = true
		end
	end
end

-- data structure for nodes
local node_start = {}

-- keep track of which players are awake
local last_seen_awake = {}

-- runs once during ReadyCommand
function M.compile_nodes()
	local terminators = {}
	for _, nd in ipairs(nodes) do
		for _, mod in ipairs(nd[2]) do
			terminators[mod] = true
		end
	end
	local priority = -1 * (#nodes + 1)
	for k, _ in pairs(terminators) do
		table.insert(nodes, { { k }, {}, nil, nil, nil, nil, nil, true, priority = priority })
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
				last[v] = { nd }
			elseif not last[v] then
				last[v] = { nd }
			else
				table.insert(last[v], nd)
			end
		end

		local function escapestr(s)
			return "'" .. string.gsub(s, "[\\']", '\\%1') .. "'"
		end
		local function list(code, i, sep)
			if i ~= 1 then
				code(sep)
			end
		end

		local code = stringbuilder.new()
		local function emit_inputs()
			for i, mod in ipairs(inputs) do
				list(code, i, ',')
				for j = 1, #parents[i] do
					list(code, j, '+')
					code('parents[')(i)('][')(j)('][pn][')(escapestr(mod))(']')
				end
				if not parents[i][0] then
					list(code, #parents[i] + 1, '+')
					code('mods[pn][')(escapestr(mod))(']')
				end
			end
		end
		local function emit_outputs()
			for i, mod in ipairs(out) do
				list(code, i, ',')
				code('outputs[pn][')(escapestr(mod))(']')
			end
			return out[1]
		end
		code('return function(outputs, parents, mods, fn)\n')('return function(pn)\n')
		if terminator then
			code('mods[pn][')(escapestr(inputs[1]))('] = ')
			emit_inputs()
			code('\n')
		else
			if emit_outputs() then
				code(' = ')
			end
			code('fn(')
			emit_inputs()
			code(', pn)\n')
		end
		code('end\n')('end\n')

		local compiled = assert(loadstring(code:build(), 'node_generated'))()
		nd[6] = compiled(outputs, parents, mods, fn)
		if terminator then
			for i, mod in ipairs(inputs) do
				touch_mod(mod)
			end
		else
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

local funcs_index = 1
local active_funcs = perframedatastructure.new(function(a, b)
	local x, y = a.priority, b.priority
	return x * x * y < x * y * y
end)

function M.runeases(beat, time)
	-- {start_beat, len, ease, p0, m0, p1, m1, p2, m2, p3, m3}
	-- `eases` is the full sorted timeline of every ease
	-- `eases_index` is pointing to the next ease in the timeline that hasn't started yet
	while eases_index <= #eases do
		local e = eases[eases_index]
		-- The ease measures timings by beat by default, or time if time=true was set
		local measure = e.time and time or beat
		-- if it's not ready, break out of the loop
		-- the eases table is sorted, so none of the later eases will be done either
		if measure < e[1] then
			break
		end

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
					if not (e.exclude and e.exclude[mod]) and targets[plr][mod] ~= default_mods[mod] then
						table.insert(e, default_mods[mod])
						table.insert(e, mod)
					end
				end
			end
		end

		-- If the ease value ends with 0.5 or more, the ease should "stick".
		-- Ie, if you use outExpo, the value should stay on until turned off.
		local ease_ends_at_different_position = e[3](1) >= 0.5
		e.offset = ease_ends_at_different_position and 1 or 0

		for i = 4, #e, 2 do
			-- If it isn't using relative already, it needs to be adjusted to be relative
			-- (ie, like 'add', not like 'ease')
			-- Adjusted based on what the current target is set to
			-- This is the reason why the sorting the eases table needs to be stable.
			if not e.relative then
				local mod = e[i + 1]
				e[i] = e[i] - targets[plr][mod]
			end

			-- Update the target if it needs to be updated
			if ease_ends_at_different_position then
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

function M.runfuncs(beat, time)
	while funcs_index <= #funcs do
		local e = funcs[funcs_index]
		local measure = e.time and time or beat
		if measure < e[1] then
			break
		end
		if not e[2] then
			e[3](measure)
		elseif measure < e[1] + e[2] then
			active_funcs:add(e)
		end
		funcs_index = funcs_index + 1
	end

	while true do
		local e = active_funcs:next()
		if not e then
			break
		end
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
function M.runnodes()
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

function M.runmods()
	-- each player is processed separately
	for pn = 1, max_pn do
		-- if the player is active
		if P[pn] and P[pn]:IsAwake() then
			local buffer = mod_buffer[pn]
			-- toss everything that isn't an aux into the buffer
			for mod, percent in pairs(mods[pn]) do
				if not auxes[mod] then
					buffer[#buffer + 1] = '*-1 ' .. percent .. ' ' .. mod
				end
				mods[pn][mod] = nil
			end
			-- if the buffer has at least 1 item in it
			-- then pass it to ApplyModifiers
			if buffer[1] then
				apply_modifiers(table.concat(buffer, ','), pn)
				utils.iclear(buffer)
			end
		end
	end
end

function M.printtargets(beat)
	if debug_print_mod_targets == true or debug_print_mod_targets < beat then
		for pn = 1, max_pn do
			if P[pn] and P[pn]:IsAwake() then
				local outputs = {}
				local i = 0
				for k, v in pairs(targets[pn]) do
					if v ~= default_mods[k] then
						i = i + 1
						outputs[i] = tostring(k) .. ': ' .. tostring(v)
					end
				end
				print('Player ' .. pn .. ' at beat ' .. beat .. ' --> ' .. table.concat(outputs, ', '))
			else
				print('Player ' .. pn .. ' is asleep')
			end
		end
		debug_print_mod_targets = (debug_print_mod_targets == true)
	end
end

return M
