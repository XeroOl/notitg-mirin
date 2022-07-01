local mock = {}
GAMESTATE = {}
local Song = {}
function GAMESTATE:GetCurrentSong()
	return Song
end

local mods = {}
for pn = 1, 8 do
	mods[pn] = {}
end

function GAMESTATE:ApplyModifiers(str, pn)
	for percent, mod in str:gmatch('*-1 ([^ ,]+) ([^ ,]+)') do
		mods[pn][mod] = percent
	end
end

function mock.get_mod(str, pn)
	return mods[pn or 1][str]
end

DISPLAY = {}
SCREEN_CENTER_X = 320
SCREEN_CENTER_Y = 240
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

local offset = 1
local time = offset
local beat = 0
local factor = 3
function GAMESTATE:GetSongTime()
	return time
end

function GAMESTATE:GetSongBeat()
	return beat
end

function GAMESTATE:GetFileStructure(path)
	if mock.file_override[path] then return true end
	local file = io.open(path)
	if file then
		file:close()
		return true
	end
end

function mock.advance_time(dt)
	time = time + 1 / factor * dt
	beat = beat + dt
end

function Song:GetSongDir()
	return ''
end

function Song:GetElapsedTimeFromBeat(b)
	return b / factor + offset
end

function DISPLAY:GetDisplayWidth()
	return 800
end

function DISPLAY:GetDisplayHeight()
	return 600
end

local Actor = {}
local Actor_mt = {__index = Actor}

local ActorFrame = setmetatable({}, Actor_mt)
local ActorFrame_mt = {__index = ActorFrame}

local Player = setmetatable({}, Actor_mt)
local Player_mt = {__index = Player}

mock.actors = {}

function mock.newactor(name)
	local result = setmetatable({
		_name = name,
		_commands = {},
		_queue = {},
	}, Actor_mt)
	table.insert(mock.actors, result)
	return result
end

function mock.newplayer(name)
	local result = setmetatable({
		_name = name,
		_commands = {},
		_queue = {},
	}, Player_mt)
	table.insert(mock.actors, result)
	return result
end

function mock.newactorframe(name)
	local result = setmetatable({
		_name = name,
		_commands = {},
		_queue = {},
		_children = {},
	}, ActorFrame_mt)
	table.insert(mock.actors, result)
	return result
end

function Actor:sleep(time)
end

function Actor:GetName()
	return self._name or ''
end

function Actor:hidden(i)
	if i == 0 then
		self._hidden = nil
	else
		self._hidden = true
	end
end

function Actor:addcommand(name, command)
	assert(type(name) == 'string')
	assert(type(command) == 'function')
	self._commands[name] = command
end

function Actor:queuecommand(name)
	table.insert(self._queue, name)
end

function Actor:playcommand(name)
	if self._commands[name] then
		self._commands[name](self)
	end
	if self._children then
		for i, v in ipairs(self._children) do
			v:playcommand(name)
		end
	end
end

function Actor:removecommand(name)
	self._commands[name] = nil
end

function Actor:luaeffect(name)
	self._effect = name
end

function Actor:effectclock()
end

function Actor:GetSecsIntoEffect()
	return time
end

function ActorFrame:GetNumChildren()
	return #self._children
end

function ActorFrame:GetChildAt(n)
	return self._children[n + 1]
end

function Player:IsAwake()
	return self._name == "PlayerP1" or self._name == "PlayerP2"
end

function Player:SetInputPlayer(pn)
end

local screen_world = {}
local deleted_players = {}
SCREENMAN = setmetatable({}, {__call = function(self, arg)
	if arg and arg:match('^PlayerP[1-8]$') then
		if deleted_players[tonumber(arg:match('^PlayerP([1-8])'))] then
			return nil
		end
		screen_world[arg] = screen_world[arg] or mock.newplayer(arg)
	end
	screen_world[arg] = screen_world[arg] or mock.newactor(arg)
	local thing_to_hide = screen_world[arg]
	return thing_to_hide
end})

function mock.delete_player(pn)
	deleted_players[pn] = true
end

function SCREENMAN:SystemMessage(message)
	error(message)
end

function mock.add_child(parent, child)
	table.insert(parent._children, child)
end

return mock
