local utils = require('core.utils')

-- Move global functions to the xero table, allowing for slightly faster
-- performance due to not having to go back and forth between xero and _G.
local old = _G.xero
assert(xero.xero == _G.xero)
xero.xero = _G.xero
assert(old == _G.xero)

xero.type = _G.type
xero.print = _G.print
xero.pairs = _G.pairs
xero.ipairs = _G.ipairs
xero.unpack = _G.unpack
xero.tonumber = _G.tonumber
xero.tostring = _G.tostring
xero.math = utils.copy(_G.math)
xero.table = utils.copy(_G.table)
xero.string = utils.copy(_G.string)

xero.scx = SCREEN_CENTER_X
xero.scy = SCREEN_CENTER_Y
xero.sw = SCREEN_WIDTH
xero.sh = SCREEN_HEIGHT

xero.dw = DISPLAY:GetDisplayWidth()
xero.dh = DISPLAY:GetDisplayHeight()

xero.max_pn = require('core.options').max_pn

xero()
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
