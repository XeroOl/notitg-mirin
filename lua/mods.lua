LoadTemplate()

if not P1 or not P2 then
	SCREENMAN:SystemMessage('Two Player Mode Required')
	print('Two Player Mode Required')
	GAMESTATE:FinishSong()
	foreground:hidden(1)
	return
end

-- judgment proxies
for pn = 1, 2 do
	local judge = P[pn]:GetChild('Judgment')
	PJ[pn]:SetTarget(judge)
	PJ[pn]:xy(pn == 1 and scx-160 or scx+160, scy)
	judge:hidden(1)
	judge:sleep(9e9)
end

-- combo proxies
for pn = 1, 2 do
	local combo = P[pn]:GetChild('Combo')
	PC[pn]:SetTarget(combo)
	PC[pn]:xy(pn == 1 and scx-160 or scx+160, scy)
	combo:hidden(1)
	combo:sleep(9e9)
end

-- player proxies
for pn = 1, #PP do
	PP[pn]:SetTarget(P[pn])
	P[pn]:xy(pn == 1 and scx-160 or scx+160, scy)
	P[pn]:hidden(1)
end

-- your code goes here here:
