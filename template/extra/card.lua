local spellcards = {}

local function addspellcards()
	local s = GAMESTATE:GetCurrentSong()
	s:SetNumSpellCards(#spellcards)
	table.sort(spellcards, function(a, b)
		return a.beat < b.beat
	end)
	for i, card in ipairs(spellcards) do
		local i = i - 1
		if type(card.color) ~= 'table' then
			local color = {}
			for m in (string.gmatch or string.gfind)(card.color, '[a-fA-F0-9][a-fA-F0-9]') do
				table.insert(color, tonumber(m, 16) / 255)
			end
			color[4] = color[4] or 1
			card.color = color
		end

		s:SetSpellCardTiming(i, card.beat, card.endbeat)
		s:SetSpellCardName(i, card.name)
		s:SetSpellCardDifficulty(i, card.diff)
		s:SetSpellCardColor(
			i,
			card.color[1] or card.color.r,
			card.color[2] or card.color.g,
			card.color[3] or card.color.b,
			card.color[4] or card.color.a or 1
		)
	end
end

local function card(t)
	if not spellcards[1] then
		require('mirin.api.classic').func { 0, addspellcards }
	end
	table.insert(spellcards, { beat = t[1], endbeat = t[2], name = t[3], diff = t[4], color = t[5] })
	return card
end

return card
