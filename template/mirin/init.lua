local options = require('mirin.options')
local utils = require('mirin.utils')
local sort = require('mirin.utils.sort')
local stringbuilder = require('mirin.utils.stringbuilder')
local perframedatastructure = require('mirin.utils.perframedatastructure')

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
	package.loaded['mirin.api.actors'] = actors
end

local P = {}
M.P = P
local default_inputs = {
	[1] = 'P1',
	[2] = 'P2',
	[3] = 'P1',
	[4] = 'P2',
	[5] = 'P1',
	[6] = 'P2',
	[7] = 'P1',
	[8] = 'P2',
}

local function setup_player_inputs()
	local inputs = options.inputs or default_inputs
	local input_names = {
		P1 = SCREENMAN('PlayerP1') and 0 or 1,
		P2 = SCREENMAN('PlayerP2') and 1 or 0,
		AUTO = 2,
	}
	for pn = 1, max_pn do
		local player = xero.P[pn]
		if player then
			local input_player = input_names[inputs[pn] or default_inputs[pn]]
			if not input_player then
				error('Unknown input in configuration: ' .. tostring(inputs[pn]))
			end
			player:SetInputPlayer(input_player)
		end
	end
end

function M.setup_players()
	local i = 1
	for pn = 1, max_pn do
		local player
		while not player and i <= 8 do
			player = SCREENMAN('PlayerP' .. i)
			i = i + 1
		end
		rawset(xero, 'P' .. pn, player)
		P[pn] = player
	end
	rawset(xero, 'P', P)
	setup_player_inputs()
end

-- runs once during ScreenReadyCommand, after the user code is loaded
-- sorts the mod tables so that things can be processed in order
-- after the mod tables are sorted, no more calls to table-inserting functions are allowed
function M.sort_tables()
	local function priority_comparator(a, b)
		-- For priorities, negative numbers trump positive numbers,
		-- so -1 is the greatest priority, and 1 is the smallest priority
		if a < 0 and b >= 0 then
			return false
		end
		if a >= 0 and b < 0 then
			return true
		end
		return a < b
	end

	local function eases_comparator(a, b)
		if a.start_time ~= b.start_time then
			return a.start_time < b.start_time
		else
			-- resets win the tie breaker
			return a.reset and not b.reset
		end
	end
	sort.stable_sort(eases, eases_comparator)

	local function funcs_comparator(a, b)
		if a.start_time ~= b.start_time then
			return a.start_time < b.start_time
		else
			return priority_comparator(a.priority, b.priority)
		end
	end
	sort.stable_sort(funcs, funcs_comparator)

	sort.stable_sort(nodes, function(a, b)
		return priority_comparator(a.priority, b.priority)
	end)
end

local function resolve_aliases_for_aux()
	local old_auxes = utils.copy(auxes)
	utils.clear(auxes)
	for mod, _ in pairs(old_auxes) do
		-- auxes bypass name checks
		auxes[M.normalize_mod_no_checks(mod)] = true
	end
end

local function resolve_aliases_for_ease()
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
end

local function resolve_aliases_for_node()
	for _, node in ipairs(nodes) do
		for i = 1, #node.inputs do
			node.inputs[i] = M.normalize_mod(node.inputs[i])
		end
		for i = 1, #node.outputs do
			node.outputs[i] = M.normalize_mod(node.outputs[i])
		end
	end
end

local function resolve_aliases_for_default_mods()
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

-- runs once during ScreenReadyCommand, after the user code is loaded
-- replaces aliases with their respective mods
function M.resolve_aliases()
	resolve_aliases_for_aux()
	resolve_aliases_for_ease()
	resolve_aliases_for_node()
	resolve_aliases_for_default_mods()
end

-- keep track of which players are awake
local last_seen_awake = {}

-- data structure for nodes
local startnodes = {}

do -- all code related to processing nodes -- redone by chegg
	local function add_terminators()
		local terminators = {}
		for _, node in ipairs(nodes) do
			for _, mod in ipairs(node.outputs) do
				terminators[mod] = mod
			end
		end

		for _, mod in pairs(terminators) do
			table.insert(nodes, {
				inputs = { mod },
				outputs = {},
				terminator = true,
			})
		end
	end

	local function create_edges()
		local writers = {}
		for _, node in ipairs(nodes) do
			node.children = {}
			node.parents = {}
			if not node.terminators then
				node.results = {}
			end
			for _, mod in ipairs(node.outputs) do
				writers[mod] = writers[mod] or {}
				table.insert(writers[mod], node)
				node.results[mod] = {}
			end
		end

		for _, node in ipairs(nodes) do
			for _, mod in ipairs(node.inputs) do
				startnodes[mod] = startnodes[mod] or {}
				table.insert(startnodes[mod], node)

				if writers[mod] then
					for _, parent in ipairs(writers[mod]) do
						node.parents[mod] = node.parents[mod] or {}

						table.insert(parent.children, node)
						table.insert(node.parents[mod], parent.results[mod])
					end
				end
			end
		end
	end

	local function sort_nodes()
		local sorted = {}
		local seen = 0
		local function visit(node)
			if node.seen == 2 then
				return
			end
			if node.seen == 1 then
				local err = stringbuilder.new()
				err('Node Complilation Error: Recursive node dependency detected in node with inputs (')
				err(table.concat(node.inputs), ', ')
				err(') and outputs (')
				err(table.concat(node.outputs), ', ')
				err(').')
				error(err)
			end
			node.seen = 1

			for _, child in ipairs(node.children) do
				visit(child)
			end

			node.seen = 2
			seen = seen + 1
			table.insert(sorted, node)
		end
		local i = 1
		while seen ~= #nodes do
			visit(nodes[i])
			i = (i % #nodes) + 1
		end
		return sorted
	end

	local function compile_nodes()
		local function escapestr(s)
			return "'" .. string.gsub(s, "[\\']", '\\%1') .. "'"
		end

		local function list(code, str, i)
			if i > 1 then
				code(str)
			end
		end

		local function append_outputs(code, node)
			for i, mod in ipairs(node.outputs) do
				list(code, ',', i)
				code('results[')(escapestr(mod))('][pn]')
			end
		end

		local function append_inputs(code, node)
			for i, mod in ipairs(node.inputs) do
				list(code, ',', i)
				if node.parents[mod] then
					for j = 1, #node.parents[mod] do
						list(code, '+', j)
						code('parents[')(escapestr(mod))('][')(j)('][pn]')
					end
					list(code, '+', #node.parents[mod] + 1)
				end
				code('mods[pn][')(escapestr(mod))(']')
			end
		end

		for i = #nodes, 1, -1 do
			local node = nodes[i]
			local code = stringbuilder:new()
			code('return function(parents, results, fn, mods) return function(pn)')
			if not node.terminator then
				if #node.outputs > 0 then
					append_outputs(code, node)
					code('=')
				end
				code('fn(')
				append_inputs(code, node)
				code(', pn)')
			else
				code('mods[pn][')(escapestr(node.inputs[1]))('] = \n')
				append_inputs(code, node)
			end
			code('end end')

			local compiled = assert(loadstring(code:build(), 'node_generated'))()
			node.compfn = compiled(node.parents, node.results, node.fn, mods)
			if not node.terminator then
				for pn = 1, max_pn do
					node.compfn(pn)
				end
			else
				touch_mod(node.inputs[1])
			end
		end
	end

	function M.process_nodes()
		add_terminators()

		create_edges()

		nodes = sort_nodes()
		M.nodes = nodes

		compile_nodes()
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
			print('\nPLAYER ' .. pn .. ':\n    ' .. string.gsub(str, ',', '\n    '))
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

local seen = 0
local active_nodes = {}
local active_terminators = {}
local propagateAll, propagate
function propagateAll(nodes_to_propagate)
	if nodes_to_propagate then
		for _, node in ipairs(nodes_to_propagate) do
			propagate(node)
		end
	end
end

function propagate(node)
	if node.seen ~= seen then
		node.seen = seen
		if node.terminator then
			table.insert(active_terminators, node)
		else
			propagateAll(node.children)
			table.insert(active_nodes, node)
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
				propagateAll(startnodes[k])
			end
			for _ = 1, #active_nodes do
				-- run all the nodes
				table.remove(active_nodes).compfn(pn)
			end
			for _ = 1, #active_terminators do
				-- run all the nodes marked as 'terminator'
				table.remove(active_terminators).compfn(pn)
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