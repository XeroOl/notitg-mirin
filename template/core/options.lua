local conf = assert(loadfile(xero.dir .. 'conf.lua'))()

local defaults = {
	max_pn = 8,
	lua_entry_path = 'lua/mods.lua',
	xml_entry_path = 'lua/layout.xml',
	package_path = {
		'template/?.lua', 'template/?/init.lua',
		'lua/?.lua',      'lua/?/init.lua',
		'plugins/?.lua',  'plugins/?/init.lua',
	},
	lua_pre_entry_path = nil,
	renumber_players = true,
	inputs = {
		[1] = "P1", [2] = "P2",
		[3] = "P1", [4] = "P2",
		[5] = "P1", [6] = "P2",
		[7] = "P1", [8] = "P2",
	},
	strict = false,
	-- TODO remove prelude
	use_prelude = true,
}

for k, v in pairs(defaults) do
	if conf[k] == nil then
		conf[k] = v
	end
end

return conf
