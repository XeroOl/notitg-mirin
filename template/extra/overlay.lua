local overlay = {}

-- hide various actors that are placed by the theme
function overlay.hide(list)
	-- stylua: ignore
	for _, name in ipairs(list or { -- improved layer list thanks @bun#1087
		'Overlay', 'Underlay',
		'ScoreP1', 'ScoreP2',
		'LifeP1', 'LifeP2',
		'PlayerOptionsP1', 'PlayerOptionsP2', 'SongOptions',
		'DifficultyP1', 'DifficultyP2',
		'BPMDisplay',
		'MemoryCardDisplayP1', 'MemoryCardDisplayP2',
	}) do
		local actor = SCREENMAN:GetChild(name)
		if actor then actor:hidden(1) end
	end
end

return overlay
