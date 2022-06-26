local spellcards = {}

local function addspellcards()
	local s = GAMESTATE:GetCurrentSong()
	s:SetNumSpellCards(#spellcards)
	table.sort(spellcards, function(a, b)
		return a[1] < b[1]
	end)
	for i = 1, #spellcards do
		local a = spellcards[i]
		s:SetSpellCardTiming(i - 1, a[1], a[2])
		s:SetSpellCardName(i - 1, a[3])
		s:SetSpellCardDifficulty(i - 1, a[4])
		if type(a[5]) ~= 'table' then
			local colors = {}
			for m in (string.gmatch or string.gfind)(a[5], '[a-fA-F0-9][a-fA-F0-9]') do
				table.insert(colors, tonumber(m, 16) / 255)
			end
			colors[4] = colors[4] or 1
			a[5] = colors
		end
		s:SetSpellCardColor(i - 1, a[5][1] or a[5].r, a[5][2] or a[5].g, a[5][3] or a[5].b, a[5][4] or a[5].a or 1)
	end
end

local function card(t)
	if not spellcards[1] then
		require('core.template').func { 0, addspellcards }
	end
	table.insert(spellcards, t)
	return card
end

return card
