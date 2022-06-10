local conf = assert(loadfile(xero.dir .. 'conf.lua'))() or {}

local defaults = {
	max_pn = 8,
	actors_in_global_table = true,
	use_prelude = true,
	lua_entry_path = 'lua/mods.lua',
	xml_entry_path = 'lua/layout.xml',
	package_path = {
		'src/?.lua',
		'src/?/init.lua',
		'lua/?.lua',
		'lua/?/init.lua',
		'plugins/?.lua',
		'plugins/?/init.lua',
	},
	lua_pre_entry_path = nil,
	strict = false,
	danger = false,
}

for k, v in pairs(defaults) do
	-- explicit nil check
	if conf[k] == nil then
		conf[k] = v
	end
end

return conf
