-- runs once during ScreenReadyCommand, before the user code is loaded
-- sets up the player tables
local P = xero.P
local i = 1

if not xero.P1 or not xero.P2 then
	local real_player = xero.P1 and 0 or 1

	for pn = 1, require('core.options').max_pn do
		local player
		while not player and i < 100 do
			player = SCREENMAN('PlayerP' .. i)
			i = i + 1
		end
		xero['P' .. pn] = player
		P[pn] = player
	end

	xero.P1:SetInputPlayer(real_player)
	xero.P2:SetInputPlayer(real_player)
end
