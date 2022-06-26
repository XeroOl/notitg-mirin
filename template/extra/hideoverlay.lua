-- hide various actors that are placed by the theme
for _, element in ipairs {
	'Overlay',
	'Underlay',
	'ScoreP1',
	'ScoreP2',
	'LifeP1',
	'LifeP2',
} do
	local child = SCREENMAN(element)
	if child then
		child:hidden(1)
	end
end
