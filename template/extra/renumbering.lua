local P = xero.P

if not xero.P1 or not xero.P2 then
	local real_player = xero.P1 and 0 or 1

	local i = 1
	local max_pn = require('core.options').max_pn
	for pn = 1, max_pn do
		local player
		while not player and i <= 8 do
			player = SCREENMAN('PlayerP' .. i)
			i = i + 1
		end
		xero['P' .. pn] = player
		P[pn] = player
	end

	xero.P1:SetInputPlayer(real_player)
	xero.P2:SetInputPlayer(real_player)
end
