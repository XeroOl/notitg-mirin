xero()

max_pn = 8 -- default: `8`
local debug_print_applymodifier_input = false -- default: `false`
local debug_print_mod_targets = false -- default: `false`

-- screen_error reports an error to the screen
-- needs to be called through
local function screen_error(output, name)
	local _, err = pcall(error, type(name) == 'string' and (name .. ':' .. output) or output, 5)
	SCREENMAN:SystemMessage(err)
	return err
end

---------------------
-- DATA STRUCTURES --
---------------------

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

-- the previously set value of a mod
-- this is used only for the `get` function
local prev_mods = {}
local modtable_mt = {__index = default_mods}
for pn = 1, max_pn do
	prev_mods[pn] = setmetatable({}, modtable_mt)
end

---------------
-- FUNCTIONS --
---------------

-- the `plr=` system
local default_plr = {1, 2}

-- for reading the `plr` variable from the xero environment
-- without falling back to the global table
function get_plr()
	return rawget(xero, 'plr') or default_plr
end

-- get the previously set value of a mod
function get(modname, pn)
	return prev_mods[pn or 1][modname]
end

-- convert a mod to its lowercase dealiased name
function normalize_mod(name)
	name = string.lower(name)
	return aliases[name] or name
end

-- ease {start, len, eas, percent, 'mod'}
-- adds an ease to the ease table
local function ease(self)
	self.n = #self
	if self[3](1) < 0.5 then
		self.transient = 1
	end
	if self.mode or self.m then
		self[2] = self[2] - self[1]
	end

	local plr = self.plr or get_plr()
	if type(plr) == 'table' then
		for _, plr in ipairs(plr) do
			local copy = copy(self)
			copy.plr = plr
			table.insert(eases, copy)
		end
	else
		self.plr = plr
		table.insert(eases, self)
	end

	if not self.transient then
		-- update prev_mods table
		for _, pn in ipairs(type(plr) == 'table' and plr or {plr}) do
			if self.reset then
				for mod, percent in pairs(prev_mods[pn]) do
					if not self.exclude[mod] then
						prev_mods[pn][mod] = default_mods[mod]
					end
				end
			end
			for n = 5, self.n, 2 do
				if self.relative then
					prev_mods[pn][self[n]] = prev_mods[pn][self[n]] + self[n - 1]
				else
					prev_mods[pn][self[n]] = self[n - 1]
				end
			end
		end
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

-- reset {start, [len, eas], [exclude = {mod list}]}
-- adds a reset to the ease table
local function reset(self)
	self[2] = self[2] or 0
	self[3] = self[3] or instant
	self.reset = true
	self.exclude = self.exclude or {}
	if type(self.exclude) == 'string' then
		self.exclude = {self.exclude}
	end
	for _, v in ipairs(self.exclude) do
		self.exclude[v] = true
	end
	ease(self)
end

-- func helper for scheduling a function
local function func_function(self)
	self[2], self[3] = nil, self[2]
	local persist = self.persist
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
	self.priority = (self.defer and -1 or 1) * table.getn(funcs)
	table.insert(funcs, self)
end

-- func helper for scheduling a perframe
local function func_perframe(self, can_use_poptions)
	if can_use_poptions then
		self.mods = {}
		for pn = 1, max_pn do
			self.mods[pn] = {}
		end
	end
	self.priority = (self.defer and -1 or 1) * table.getn(funcs)
	table.insert(funcs, self)
end

-- func helper for function eases
local function func_ease(self)
	-- use the mode to adjust len
	if self.mode or self.m then
		self[2] = self[2] - self[1]
	end
	local fn = table.remove(self)
	local eas = self[3]
	local start_percent = #self >= 5 and table.remove(self, 4) or 0
	local end_percent = #self >= 4 and table.remove(self, 4) or 1
	local end_beat = self[1] + self[2]

	-- string syntax, like `func {0, 1, outExpo, scx*0.5, scx, 'P1:x'}`
	if type(fn) == 'string' then
		fn = xero(loadstring('return function(p) '..fn..'(p) end'))()
	end

	self[3] = function(beat)
		local progress = (beat - self[1]) / self[2]
		fn(start_percent + (end_percent - start_percent) * eas(progress))
	end

	func_perframe(self)
	-- it's a function-ease variant, so make it persist
	if self.persist ~= false then
		func_function {
			end_beat,
			function()
				fn(end_percent)
			end,
			persist = self.persist,
			defer = self.defer,
			mode = self.mode
		}
	end
end

-- func dispatcher
local function func(self)
	-- scheduled function variant
	if #self == 2 then
		func_function(self)

	-- basic perframe variant
	elseif #self == 3 then
		func_perframe(self, true)

	-- function ease variant
	else
		func_ease(self)
	end
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
		touch_mod(self[i + 1])
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
	result.priority = (self.defer and -1 or 1) * table.getn(nodes)
	table.insert(nodes, result)
	return node
end

-- definemod{'mod', function(mod, pn) end}
-- calls aux and node on the provided arguments
local function definemod(self)
	local depth = 1 + (type(depth) == 'number' and depth or 0)
	local name = name or 'definemod'
	for i = 1, #self do
		if type(self[i]) ~= 'string' then
			break
		end
		aux(self[i])
	end
	node(self)
	return definemod
end

-------------
-- RUNTIME --
-------------

-- mod targets are the values that the mod would be at if the current eases finished
local targets = {}
for pn = 1, max_pn do
	targets[pn] = setmetatable({}, modtable_mt)
end

-- the live value of the current mods. Gets recomputed each frame
local mods = {}
local mods_mt = {}
for pn = 1, max_pn do
	mods_mt[pn] = {__index = targets[pn]}
	mods[pn] = setmetatable({}, mods_mt[pn])
end

-- a stringbuilder of the modstring that is being applied
mod_buffer = stringbuilder()

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
		__index = function(self, k)
			return mods_pn[normalize_mod(k)]
		end,
		__newindex = function(self, k, v)
			k = normalize_mod(k)
			mods_pn[k] = v
			if v then
				poptions_logging_target[pn][k] = true
			end
		end,
	}
	poptions[pn] = setmetatable({}, mt)
end

function touch_mod(mod, pn)
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

function touch_all_mods(pn)
	for mod in pairs(default_mods) do
		touch_mod(mod)
	end
	if pn then
		for mod in pairs(targets[pn]) do
			touch_mod(mod, pn)
		end
	else
		for pn = 1, 8 do
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
local function prepare_variables()
	P = {}
	for pn = 1, max_pn do
		local player = SCREENMAN('PlayerP' .. pn)
		xero['P' .. pn] = player
		P[pn] = player
	end
end

-- runs once during ScreenReadyCommand, after the user code is loaded
-- sorts the mod tables so that things can be processed in order
local function sort_tables()
	-- sort eases by their beat
	stable_sort(eases, function(a, b) return a[1] < b[1] end)

	-- sort the funcs by their beat and priority
	stable_sort(funcs, function(a, b)
		if a[1] == b[1] then
			local x, y = a.priority, b.priority
			return x * x * y < x * y * y
		else
			return a[1] < b[1]
		end
	end)

	-- sort the nodes by their priority
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
		for i = 5, e.n, 2 do e[i] = normalize_mod(e[i]) end
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
		default_mods[normalize_mod(mod)] = percent
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
	for k, _ in pairs(terminators) do
		table.insert(nodes, {{k}, {}, nil, nil, nil, nil, nil, true})
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
		for i, v in ipairs(out) do
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

		local compiled = assert(loadstring(code:build()))()
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

local function disable_functions()
	ease = function() screen_error('cannot be run after beat 0', 'ease') end
	add = function() screen_error('cannot be run after beat 0', 'add') end
	func = function() screen_error('cannot be run after beat 0', 'func') end
	set = function() screen_error('cannot be run after beat 0', 'set') end
	setdefault = function() screen_error('cannot be run after beat 0', 'setdefault') end
	reset = function() screen_error('cannot be run after beat 0', 'reset') end
	node = function() screen_error('cannot be run after beat 0', 'node') end
	definemod = function() screen_error('cannot be run after beat 0', 'definemod') end
	aux = function() screen_error('cannot be run after beat 0', 'aux') end
	alias = function() screen_error('cannot be run after beat 0', 'alias') end
	get = function(mod, pn) return mods[pn or 1][normalize_mod(mod)] end
end

function screen_ready_command(self)
	hide_theme_actors()
	prepare_variables()
	foreground:hidden(0)
	-- loads both the plugins and the mod.xml due to propagation
	foreground:playcommand('Load')
	sort_tables()
	resolve_aliases()
	compile_nodes()
	-- disable all the table inserters during runtime
	disable_functions()
	self:luaeffect('Update')
end

local function apply_modifiers(str, pn)
	GAMESTATE:ApplyModifiers(str, pn)
end

if debug_print_applymodifier_input then
	local old_apply_modifiers = apply_modifiers
	apply_modifiers = function(str, pn)
		if debug_print_applymodifier_input == true or debug_print_applymodifier_input < beat then
			print('PLAYER ' .. pn .. ': ' .. str)
			if debug_print_applymodifier_input ~= true then
				apply_modifiers = old_apply_modifiers
			end
		end
		GAMESTATE:ApplyModifiers(str, pn)
	end
end

local eases_index = 1
local active_eases = {}
local function run_eases(beat)
	while eases_index <= #eases and eases[eases_index][1] < beat do
		local e = eases[eases_index]
		local plr = e.plr
		if e.reset then
			for mod, pecent in pairs(targets[plr]) do
				if not e.exclude[mod] and targets[plr][mod] ~= default_mods[mod] then
					table.insert(e, default_mods[mod])
					table.insert(e, mod)
				end
			end
		end
		e.offset = e.transient and 0 or 1
		if not e.relative then
			for i = 4, e.n, 2 do
				local mod = e[i + 1]
				e[i] = e[i] - targets[plr][mod]
			end
		end
		if not e.transient then
			for i = 4, e.n, 2 do
				local mod = e[i + 1]
				targets[plr][mod] = targets[plr][mod] + e[i]
			end
		end
		table.insert(active_eases, e)
		eases_index = eases_index + 1
	end

	local active_eases_index = 1
	while active_eases_index <= table.getn(active_eases) do
		local e = active_eases[active_eases_index]
		local plr = e.plr
		if beat < e[1] + e[2] then
			local e3 = e[3]((beat - e[1]) / e[2]) - e.offset
			for i = 4, e.n, 2 do
				local mod = e[i + 1]
				mods[plr][mod] = mods[plr][mod] + e3 * e[i]
			end
			active_eases_index = active_eases_index + 1
		else
			for i = 4, e.n, 2 do
				local mod = e[i + 1]
				touch_mod(mod, plr)
			end
			active_eases[active_eases_index] = table.remove(active_eases)
		end
	end
end

local funcs_index = 1
local active_funcs = perframe_data_structure(function(a, b)
	local x, y = a.priority, b.priority
	return x * x * y < x * y * y
end)
local function run_funcs(beat)
	while funcs_index <= #funcs and funcs[funcs_index][1] < beat do
		local e = funcs[funcs_index]
		if not e[2] then
			e[3](beat)
		elseif beat < e[1] + e[2] then
			active_funcs:add(e)
		end
		funcs_index = funcs_index + 1
	end

	while true do
		local e = active_funcs:next()
		if not e then break end
		if beat < e[1] + e[2] then
			poptions_logging_target = e.mods
			e[3](beat, poptions)
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
function propagateAll(nodes)
	if nodes then
		for _, nd in ipairs(nodes) do
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

local function run_nodes_and_mods()
	for pn = 1, max_pn do
		if P[pn] and P[pn]:IsAwake() then
			if not last_seen_awake[pn] then
				last_seen_awake[pn] = true
				for mod, percent in pairs(touched_mods[pn]) do
					touch_mod(mod, pn)
					touched_mods[pn][mod] = nil
				end
			end
			mod_buffer:clear()
			seen = seen + 1
			for k in pairs(mods[pn]) do
				-- identify all nodes to execute this frame
				propagateAll(node_start[k])
			end
			for i = 1, #active_nodes do
				-- run all the nodes
				table.remove(active_nodes)[6](pn)
			end
			for i = 1, #active_terminators do
				-- run all the nodes marked as 'terminator'
				table.remove(active_terminators)[6](pn)
			end
			for mod, percent in pairs(mods[pn]) do
				if not auxes[mod] then
					mod_buffer('*-1 '..percent..' '..mod)
				end
				mods[pn][mod] = nil
			end
			if mod_buffer[1] then
				apply_modifiers(mod_buffer:build(','), pn)
			end
		else
			last_seen_awake[pn] = false
			for mod, percent in pairs(mods[pn]) do
				mods[pn][mod] = nil
				touched_mods[pn][mod] = true
			end
		end
	end
end

local function run_debug_print_mod_targets(beat)
	if debug_print_mod_targets then
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
				end
			end
			debug_print_mod_targets = (debug_print_mod_targets == true)
		end
	end
end

local oldtime = 0
function update_command(self)
	local beat = GAMESTATE:GetSongBeat()
	local time = GAMESTATE:GetSongTime()

	-- don't run multiple times if the game hasn't 'ticked' yet
	if time == oldtime then return end
	oldtime = time

	run_eases(beat)
	run_funcs(beat)
	run_nodes_and_mods()
	run_debug_print_mod_targets(beat)
end

---------------------------------------------------------------------------------------
GAMESTATE:ApplyModifiers('clearall,*-1 overhead')

-- Shorthand for commonly used variables
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

function aftsprite(aft, sprite)
	sprite:SetTexture(aft:GetTexture())
end

function setupJudgeProxy(proxy, target, pn)
	proxy:SetTarget(target)
	proxy:xy(scx * (pn-.5), scy)
	target:hidden(1)
	target:sleep(9e9)
end

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
	function(xmod, cmod)
		if cmod == 0 then
			mod_buffer(string.format('*-1 %fx', xmod))
		else
			mod_buffer(string.format('*-1 %fx,*-1 c%f', xmod, cmod))
		end
	end,
	defer = true,
}

--------------------
-- ERROR CHECKING --
--------------------

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
		return screen_error('curly braces expected', name)
	end
	if type(self[1]) ~= 'number' then
		return screen_error('beat missing', name)
	end
	if name ~= 'set' then
		if type(self[2]) ~= 'number' then
			return screen_error('len / end missing', name)
		end
		if not is_valid_ease(self[3]) then
			return screen_error('invalid ease function', name)
		end
	end
	local i = is_set and 2 or 4
	while self[i] do
		if type(self[i]) ~= 'number' then
			return screen_error('invalid mod percent', name)
		end
		if type(self[i + 1]) ~= 'string' then
			return screen_error('invalid mod', name)
		end
		i = i + 2
	end
	local plr = self.plr or get_plr()
	if type(plr) ~= 'number' and type(plr) ~= 'table' then
		return screen_error('invalid plr', name)
	end
end

local function check_reset_errors(self, name)
	if type(self) ~= 'table' then
		return screen_error('curly braces expected', name)
	end
	if type(self[1]) ~= 'number' then
		return screen_error('invalid beat number', name)
	end
	if self[2] and self[3] then
		if type(self[2]) ~= 'number' then
			return screen_error('invalid length', name)
		end
		if not is_valid_ease(self[3]) then
			return screen_error('invalid ease', name)
		end
	elseif self[2] or self[3] then
		return screen_error('needs both length and ease', name)
	end
	if type(self.exclude) ~= 'nil' and type(self.exclude) ~= 'string' and type(self.exclude) ~= 'table' then
		return screen_error('invalid `exclude=`', name)
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
}

function check_func_errors(self, name)
	if type(self) ~= 'table' then
		return screen_error('curly braces expected', name)
	end
	local types = stringbuilder()
	for i, v in ipairs(self) do
		types(type(v))
	end
	if #self >= 3 then
		if is_valid_ease(self[3]) then
			types[3] = 'ease'
		end
	end
	local signature = types:build(', ')
	if signature == 'number, number, function' and self.persist ~= nil then
		return screen_error('persist is not supported for perframes', name)
	end
	if not valid_func_signatures[signature] then
		return screen_error('something is wrong with your func', name)
	end
end

local function check_alias_errors(self, name)
	if type(self) ~= 'table' then
		return screen_error('curly braces expected', name)
	end
	local a, b = self[1], self[2]
	if type(a) ~= 'string' then
		return screen_error('argument 1 should be a string', name)
	end
	if type(b) ~= 'string' then
		return screen_error('argument 2 should be a string', name)
	end
end

local function check_setdefault_errors(self, name)
	if type(self) ~= 'table' then
		return screen_error('curly braces expected', name)
	end
	for i = 1, #self, 2 do
		if type(self[i]) ~= 'number' then
			return screen_error('invalid mod percent', name)
		end
		if type(self[i + 1]) ~= 'string' then
			return screen_error('invalid mod name', name)
		end
	end
end

local function check_aux_errrors(self, name)
	if type(self) ~= 'string' and type(self) ~= 'table' then
		return screen_error('expecting curly braces', name)
	end
	if type(self) == 'table' then
		for i, v in ipairs(self) do
			if type(v) ~= 'string' then
				return screen_error('invalid mod to aux: '.. v, name)
			end
		end
	end
end

local function check_node_errors(self, name)
	if type(self) ~= 'table' then
		return screen_error('curly braces expected', name)
	end
	local i = 1
	while type(self[i]) == 'string' do
		i = i + 1
	end
	if i == 1 then
		return screen_error('the first argument needs to be the mod name', name)
	end
	if type(self[i]) ~= 'function' then
		return screen_error('mod definition expected', name)
	end
	i = i + 1
	while self[i] do
		if type(self[i]) ~= 'string' then
			return screen_error('unexpected argument '..tostring(self[i])..', expected a string', name)
		end
	end
end

-------------
-- EXPORTS --
-------------

local function export(fn, check_errors, name)
	local function inner(self)
		if not check_errors(self, name) then
			fn(self)
		end
		return inner
	end
	xero[name] = inner
end

export(ease, check_ease_errors, 'ease')
export(add, check_ease_errors, 'add')
export(set, check_ease_errors, 'set')
export(reset, check_reset_errors, 'reset')
export(func, check_func_errors, 'func')
export(alias, check_alias_errors, 'alias')
export(setdefault, check_setdefault_errors, 'setdefault')
export(aux, check_aux_errrors, 'aux')
export(node, check_node_errors, 'node')
export(definemod, check_node_errors, 'definemod')

return function(self)

	-- Register the commands to the actor
	self:addcommand('On', on_command)
	self:addcommand('ScreenReady', screen_ready_command)

	function skip_first_update()
		self:removecommand('Update')
		self:addcommand('Update', update_command)
	end
	self:addcommand('Update', skip_first_update)

	-- NotITG and OpenITG have a long standing bug where the InitCommand on an actor can run twice in certain cases.
	-- By removing the command after it's done, it can only ever run once
	self:removecommand('Init')

end
