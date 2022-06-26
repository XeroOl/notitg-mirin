local helper = {}
local mock

function helper.reset()
	mock = dofile('./spec/mock.lua')
	xero = nil
end

function helper.get_mod(mod, pn)
	return mock.get_mod(mod, pn)
end

function helper.round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function helper.init(skip_exports, v6)
	local body = io.open('./template/main.xml'):read('*a')
	local initcommand = 'return ' .. body:match('"%%(.-)"')
	local h = helper

	h.foreground = mock.newactorframe()
	initcommand = assert(loadstring(initcommand, "template/main.xml"))()
	initcommand(h.foreground)

	xero.package.preload.mods = function() end

	h.template = mock.newactor()
	h.template:addcommand('Init', xero.require('template.commands').init)
	h.template:playcommand('Init')

	h.layout = mock.newactorframe()
	mock.add_child(h.foreground, h.layout)
	local pp1 = mock.newactor('PP[1]')
	local pp2 = mock.newactor('PP[2]')
	local pc1 = mock.newactor('PC[1]')
	local pc2 = mock.newactor('PC[2]')
	local pj1 = mock.newactor('PJ[1]')
	local pj2 = mock.newactor('PJ[2]')
	mock.add_child(h.layout, pp1)
	mock.add_child(h.layout, pp2)
	mock.add_child(h.layout, pc1)
	mock.add_child(h.layout, pc2)
	mock.add_child(h.layout, pj1)
	mock.add_child(h.layout, pj2)
	if not skip_exports then
		local spill = xero.require('template.utils').spill
		spill(xero.require('mirin.eases'))
		if not v6 then
			spill(xero.require('mirin.template'))
		else
			spill(xero.require('mirin.v6'))
		end
	end
end

function helper.on()
	for _, v in ipairs(mock.actors) do
		if v._commands.On then
			v:playcommand('On')
		end
	end
	mock.on_happened = true
	local spill = xero.require('template.utils').spill
	spill(xero.require('mirin.actors'))
	helper.update(0)
end

function helper.update(dt)
	if not mock.on_happened then helper.on() end
	mock.advance_time(dt or 1 / 60)
	for _, v in ipairs(mock.actors) do
		while #v._queue >= 1 do
			local queued = table.remove(v._queue, 1)
			v:playcommand(queued)
		end
		if v._effect then
			v:playcommand(v._effect)
		end
	end
end

return helper
