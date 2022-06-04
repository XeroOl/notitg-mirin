-- Settings
return {

    ---------------------------------------------------------------------
    -- max_pn : Number of players being controlled by the Mirin Template.
    --
    -- NotITG has two players shown by default, but has eight players loaded.
    -- max_pn is the number of those players that the Mirin Template will control.
    -- Other players will be left alone.
    --
    -- Lowering this number will marginally improve performance.
    -- It is recommended to set to 2 if the extra players are not being used.
    --
    -- PlayerP1 and PlayerP2 will be visible by default.
    -- Other players need to be activated with the following code:
    --     P[3]:SetAwake(true)
    --     P[3]:hidden(0)
    --
    -- Of course, P[3] will only be available if max_pn is >= 3.
    --
    -- Constraints:
    --     1 <= max_pn <= 8
    --
    -- Examples:
    --     -- Don't use extra players
    --     max_pn = 2,
    --
    --     -- One player only, requires P1 to be present
    --     -- ie, playing on the left side of the machine
    --     max_pn = 1,
    --
    max_pn = 8,

    ---------------------------------------------------
    -- use_prelude : Whether or not to use the prelude.
    --
    -- When set, the file `template/prelude.lua` is loaded before
    -- the user code is.
    -- Refer to that file for details on what is in the prelude.
    --
    -- Expected Type: boolean
    --
    use_prelude = true,

    -------------------------------------------------------------------
    -- lua_entry_path : Which lua file will be loaded to run user code.
    --
    -- This is the path to the file with the user code.
    --
    -- lua_entry_path = 'lua/mods.lua',

    -----------------------------------------------------------------------
    -- xml_entry_path : Which XML file will be loaded for the actor layout.
    --
    -- This is the path to the file the user code.
    --
    -- xml_entry_path = 'lua/layout.xml',

    ---------------------------------------------------------------------
    -- package_path : This is the search path that is used by the require
    --     function to find lua modules.
    --
    -- It is a list of paths, separated by `;`, that will be searched to find
    -- lua modules.
    -- The search is done by taking each path, replacing `?` with the module
    -- name, and checking to see if the file exists.
    --
    -- See https://www.lua.org/manual/5.1/manual.html#pdf-package.loaders
    -- for more details.
    --
    -- package_path = {
    --     'template/?.lua', 'template/?/init.lua',
    --     'lua/?.lua', 'lua/?/init.lua',
    --     'plugins/?.lua', 'plugins/?/init.lua'
    -- },

    -------------------------------------------------------------
    -- lua_pre_entry_path : A lua file to load before layout.xml is loaded.
    --
    -- This file is loaded extremely early so that functions defined in the pre file will be available in during XML parsing.
    --
    -- Example:
    --     lua_pre_entry_path = 'lua/pre.lua',
    --
    -- lua_pre_entry_path = nil,

    -----------------------------------------------------
    -- strict : if you are XeroOl, then you hate globals.
    -- Imagine if you could turn them off.
    --
    -- Set this to true to see the light.
    --
    -- Expected Type: boolean
    --
    -- strict = false,

    -------------------------------------------------------
    -- danger : if you are prefixOl, then you love globals.
    --
    -- When set, `local` will be a syntax error, and all
    -- writes to to the `xero` table will write back to _G.
    --
    -- danger = false,

}
