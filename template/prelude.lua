---@diagnostic disable: lowercase-global
local template = require('mirin.template')
local core = require('mirin.core')

max_pn = require('mirin.options').max_pn

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

-- UNDOCUMENTED

function xero.aftsprite(aft, sprite)
	sprite:SetTexture(aft:GetTexture())
end

GAMESTATE:ApplyModifiers('clearall')

-- zoom
template.aux 'zoom'
template.node {
	'zoom', 'zoomx', 'zoomy',
	function(zoom, x, y)
		local m = zoom * 0.01
		return m * x, m * y
	end,
	'zoomx', 'zoomy',
	defer = true,
}

template.setdefault {
	100, 'zoom',
	100, 'zoomx',
	100, 'zoomy',
	100, 'zoomz',
}

template.setdefault {400, 'grain'}

-- movex
local function repeat8(a)
	return a, a, a, a, a, a, a, a
end

for _, a in ipairs {'x', 'y', 'z'} do
	template.definemod {
		'move' .. a,
		repeat8,
		'move'..a..'0', 'move'..a..'1', 'move'..a..'2', 'move'..a..'3',
		'move'..a..'4', 'move'..a..'5', 'move'..a..'6', 'move'..a..'7',
		defer = true,
	}
end

-- xmod
template.setdefault {1, 'xmod'}
template.definemod {
	'xmod', 'cmod',
	function(xmod, cmod, pn)
		if cmod == 0 then
			core.mod_buffer[pn](string.format('*-1 %fx', xmod))
		else
			core.mod_buffer[pn](string.format('*-1 %fx,*-1 c%f', xmod, cmod))
		end
	end,
	defer = true,
}
