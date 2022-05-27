---@diagnostic disable: lowercase-global

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

