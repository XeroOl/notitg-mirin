local core = require('core')
local options = require('core.options')
local utils = require('core.utils')

local foreground = xero.foreground

local M = {}

local init, on, ready, update

-- This is the entry point of the template.
-- It sets up all of the commands used to run the template.
function init(self)
	-- This sets up a trick to get the Song time during the update command
	self:effectclock('music')

	-- Register the commands to the actor

	-- OnCommand is for resolving Name= on all the actors
	self:addcommand('On', on)

	-- ReadyCommand is called after OnCommand, and does all of the loading
	-- at the end of ReadyCommand, the tables are sorted and prepared for UpdateCommand
	self:addcommand('Ready', ready)

	-- Update command is called every frame. It is what sets the mod values every frame,
	-- and reads through everything that's been queued by the user.
	-- Delay one frame because the escape menu issue
	self:addcommand('Update', function()
		self:removecommand('Update')
		self:addcommand('Update', update)
	end)

	-- syntax error
	require('core.setup')
	if options.use_prelude then
		require('prelude')
	end
	if options.lua_pre_entry_path then
		assert(loadfile(xero.dir .. options.lua_pre_entry_path))()
	end
	if options.strict then
		local error, tostring, _G = error, tostring, _G
		local mt = getmetatable(xero)
		function mt.__newindex(_self, k, _v)
			error('Writing global in strict mode: ' .. tostring(k), 2)
		end
		function mt.__index(_self, k)
			if _G[k] ~= nil then
				return _G[k]
			end
			error('Reading bad global in strict mode: ' .. tostring(k), 2)
		end
	end

	-- NotITG and OpenITG have a long standing bug where the InitCommand on an actor can run twice in certain cases.
	-- By removing the command here (at the end of initcommand), we prevent it from being run again.
	self:removecommand('Init')
end

function on(self)
	core.scan_named_actors()
	self:queuecommand('Ready')
end

function ready(self)
	core.prepare_variables()
	foreground:hidden(0)

	-- loads both the plugins and the layout.xml due to propagation
	foreground:playcommand('Load')

	-- load the user code
	xero(assert(loadfile(xero.dir .. options.lua_entry_path)))()

	core.sort_tables()
	core.resolve_aliases()
	core.compile_nodes()

	-- TODO can we remove this or move it into compile_nodes
	for i = 1, options.max_pn do
		utils.iclear(core.mod_buffer[i])
	end

	-- load command has happened
	-- Set this variable so that ease{}s get denied past this point
	M.loaded = true

	-- make sure nodes are up to date
	core.runnodes()
	core.runmods()

	self:luaeffect('Update')
end

function update(self)
	self:hidden(1)

	local beat = GAMESTATE:GetSongBeat()
	local time = self:GetSecsIntoEffect()

	core.runeases(beat, time)
	core.runfuncs(beat, time)
	core.runnodes()
	core.runmods()

	if options.debug_print_mod_targets then
		core.printtargets(beat)
	end

	-- if no errors have occurred, unhide self
	-- to make the updatecommand run again next frame
	self:hidden(0)
end

M.init = init
M.on = on
M.ready = ready
M.update = update

return M
