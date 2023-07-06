if not P1 or not P2 then
	SCREENMAN:SystemMessage("Two Player Mode Required") -- Report the error to the user
	GAMESTATE:FinishSong() -- Force end the song
	foreground:hidden(1) -- Hide the foreground to disable update loop
	return
end
foreground:SetFarDist(10000)

-- player proxies
for pn = 1, #PP do
	PP[pn]:SetTarget(P[pn])
	P[pn]:hidden(1)
end

-- judgment proxies
for pn = 1, 2 do
	local judgment = P[pn]("Judgment")
	judgment:sleep(9e9)
	judgment:hidden(1)
	PJ[pn]:SetTarget(judgment)
	PJ[pn]:xy(scx * (pn-0.5), scy)
end

-- combo proxies
for pn = 1, 2 do
	local combo = P[pn]("Combo")
	combo:sleep(9e9)
	combo:hidden(1)
	PC[pn]:SetTarget(combo)
	PC[pn]:xy(scx * (pn-0.5), scy)
end

-- your code goes here here:

