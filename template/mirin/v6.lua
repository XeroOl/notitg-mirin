local core = require('core')
local commands = require('core.commands')

local utils = require('core.utils')
local instant = require('mirin.eases').instant

local M = {}

local song = GAMESTATE:GetCurrentSong()

-- the `plr=` system
local default_plr = { 1, 2 }

-- for reading the `plr` variable from the xero environment
-- without falling back to the global table
local function get_plr()
	return rawget(xero, 'plr') or default_plr
end

local function is_valid_ease(eas)
	local err = type(eas) ~= 'function' and (not getmetatable(eas) or not getmetatable(eas).__call)
	if not err then
		local result = eas(1)
		err = type(result) ~= 'number'
	end
	return not err
end

local function check_mod_errors(beat, len, eas, mods, opts, name)
	if type(beat) ~= 'number' then
		return 'invalid start beat'
	end
	if type(len) ~= 'number' then
		return 'invalid length'
	end
	if not is_valid_ease(eas) then
		return 'invalid ease function'
	end
	if type(mods) ~= 'table' then
		return 'invalid mods table'
	end
	for mod, percent in pairs(mods) do
		if type(mod) ~= 'string' then
			return 'invalid mod: ' .. tostring(mod)
		end
		if type(percent) ~= 'number' then
			return tostring(mod) .. ' has invalid percent'
		end
	end
	if opts ~= nil and type(opts) ~= 'table' then
		return 'invalid options table'
	end
	local plr = opts and opts.plr or get_plr()
	if type(plr) ~= 'number' and type(plr) ~= 'table' then
		return 'invalid plr option'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_set_errors(beat, mods, opts, name)
	if type(beat) ~= 'number' then
		return 'invalid start beat'
	end
	if type(mods) ~= 'table' then
		return 'invalid mods table'
	end
	for mod, percent in pairs(mods) do
		if type(mod) ~= 'string' then
			return 'invalid mod: ' .. tostring(mod)
		end
		if type(percent) ~= 'number' then
			return tostring(mod) .. ' has invalid percent'
		end
	end
	if opts ~= nil and type(opts) ~= 'table' then
		return 'invalid options table'
	end
	local plr = opts and opts.plr or get_plr()
	if type(plr) ~= 'number' and type(plr) ~= 'table' then
		return 'invalid plr option'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_reset_errors(beat, len, eas, opts, name)
	if type(beat) ~= 'number' then
		return 'invalid start beat'
	end
	if type(len) ~= 'number' then
		if is_valid_ease(eas) then
			return 'invalid length'
		end
		opts = len
	else
		if not is_valid_ease(eas) then
			return 'invalid ease function'
		end
	end
	if opts and type(opts) ~= 'table' then
		return 'invalid options table'
	end
	local plr = opts and opts.plr or get_plr()
	if type(plr) ~= 'number' and type(plr) ~= 'table' then
		return 'invalid plr option'
	end
	if opts ~= nil and opts.only and opts.exclude then
		return 'only and exclude options are mutually exclusive'
	end
	if opts then
		if opts.exclude and type(opts.exclude) ~= 'string' and type(opts.exclude) ~= 'table' then
			return 'invalid exclude option'
		end
		if opts.only and type(opts.only) ~= 'string' and type(opts.only) ~= 'table' then
			return 'invalid only option'
		end
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_func_errors(beat, fn, opts, name)
	if type(beat) ~= 'number' then
		return 'invalid start beat'
	end
	if type(fn) ~= 'function' and type(fn) ~= 'string' then
		return 'invalid function'
	end
	if type(opts) ~= 'nil' and type(opts) ~= 'table' then
		return 'invalid options table'
	end
	if commands.loaded then
		return 'cannot call ' .. name .. ' after LoadCommand finished'
	end
end

local function check_fease_errors(beat, len, eas, fn, opt)
	-- TODO FIXME funny
end

local function check_perframe_errors(beat, len, fn, opt)
	-- TODO FIXME funny
end

local function check_definemod_errors(input, fn, output, opt)
	-- TODO FIXME funny
end

local function check_node_errors(input, fn, output, opt)
	-- TODO FIXME funny
end

local function check_aux_errors(string_or_list)
	-- TODO FIXME funny
end

local function check_alias_errors(oldname, replacement)
	-- TODO FIXME funny
end

local function check_setdefault_errors(mod, opt)
	-- TODO FIXME funny
end

-- ======================================================================= --

function M.mod(beat, len, eas, mods, opts)
	local err = check_mod_errors(beat, len, eas, mods, opts, 'mod')
	if err then
		error(err, 2)
	end

	-- Create the options table if one isn't provided.
	opts = opts or {}

	-- Convert absolute time to relative if needed.
	if opts.mode == 'end' or opts.mode == 'e' then
		len = len - beat
	end

	-- The entry that will eventually be passed into the template's mods table
	local entry = { beat, len, eas }

	-- Convert the start time to seconds if it is provided in beats.
	entry.start_time = opts.time and beat or song:GetElapsedTimeFromBeat(beat)

	-- Convert the provided mods table from `{key = percent}` to `{percent, key}`.
	for mod, percent in pairs(mods) do
		table.insert(entry, percent)
		table.insert(entry, mod)
	end

	-- Parse all the optional parameters, besides plr into the mod entry.
	for opt, v in pairs(opts) do
		if opt ~= 'plr' then
			entry[opt] = v
		end
	end

	-- Parse the plr option if provided and insert new entries for all players needed.
	local plr = opts.plr or get_plr()
	if type(plr) == 'table' then
		for i, pn in ipairs(plr) do
			local new = utils.copy(entry)
			new.plr = pn
			table.insert(core.eases, new)
		end
	else
		entry.plr = plr
		table.insert(core.eases, entry)
	end
end

function M.set(beat, mods, opts)
	local err = check_set_errors(beat, mods, opts, 'set')
	if err then
		error(err, 2)
	end

	M.mod(beat, 0, instant, mods, opts)
end

function M.add(beat, len, eas, mods, opts)
	local err = check_mod_errors(beat, len, eas, mods, opts, 'add')
	if err then
		error(err, 2)
	end

	opts = opts or {}
	opts.relative = true

	M.mod(beat, len, eas, mods, opts)
end

function M.acc(beat, mods, opts)
	local err = check_set_errors(beat, mods, opts, 'acc')
	if err then
		error(err, 2)
	end

	opts = opts or {}
	opts.relative = true

	M.set(beat, mods, opts)
end

function M.reset(beat, len, eas, opts)
	local err = check_reset_errors(beat, len, eas, opts, 'reset')
	if err then
		error(err, 2)
	end

	if type(len) == 'nil' or type(len) == 'table' then
		opts = len
		len = 0
		eas = instant
	end

	opts = opts or {}
	opts.reset = true

	if opts.only then
		if type(opts.only) == 'string' then
			opts.only = { opts.only }
		end
	elseif opts.exclude then
		if type(opts.exclude) == 'string' then
			opts.exclude = { opts.exclude }
		end
		local exclude = {}
		for i = 1, #opts.exclude do
			exclude[opts.exclude[i]] = true
		end

		opts.exclude = exclude
	end

	M.mod(beat, len, eas, {}, opts)
end

function M.func(beat, fn, opts)
	local err = check_func_errors(beat, fn, opts, 'func')
	if err then
		error(err, 2)
	end

	opts = opts or {}

	local entry = { beat }

	entry[3] = fn

	-- Convert the mode into a boolean and add it to the entry
	entry.mode = opts.mode == 'end' or opts.mode == 'e'

	-- Convert persist into a number
	local persist = opts.persist
	if type(persist) == 'number' and entry.mode then
		persist = persist - beat
	end
	if persist == false then
		persist = 0.5
	end

	-- Recreate the function with the persist
	if type(persist) == 'number' then
		local oldfn = entry[3]
		local endtime = beat + persist
		entry[3] = function(b)
			if b <= endtime then
				oldfn(b)
			end
		end
	end

	-- Give the func priority a based on defer
	entry.priority = (opts.defer and -1 or 1) * (#core.funcs + 1)

	-- Convert beat to time if using time based
	entry.start_time = opts.time and beat or song:GetElapsedTimeFromBeat(beat)

	table.insert(core.funcs, entry)
end

function M.fease(beat, len, eas, fn, opt) end

function M.perframe(beat, len, fn, opt) end

-- TODO consider swap output and fn
function M.definemod(input, fn, output, opt) end

-- TODO consider swap output and fn
function M.node(input, fn, output, opt) end

function M.aux(string_or_list) end

function M.alias(oldname, replacement) end

function M.setdefault(mod, opt) end

return M
