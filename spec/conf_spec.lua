---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update
local putfile = helper.putfile

describe('conf_options', function()

    before_each(function()
        helper.reset()
    end)

    after_each(function()
        xero = nil
    end)

    local function setconf(t)
        putfile('conf.lua', function() return t end)
    end

    it('should support changing max_pn', function()
        setconf { max_pn = 4 }
        helper.init()
        local options = xero.require('core.options')
        assert(options.max_pn == 4)
        xero.set {1, 100, 'invert', plr = 5}
        update()
        assert(xero.P4)
        assert(not xero.P5)
        assert.is_nil(helper.get_mod('invert', 5))
    end)

    it('should support disabling prelude', function()
        pending('hard')
    end)

    it('should support lua entry path', function()
        local ran = false
        setconf { lua_entry_path = 'other_path.lua' }
        putfile('other_path.lua', function() ran = true end)
        putfile('lua/mods.lua', function() error('loaded the original') end)
        helper.init()
        helper.update()
        assert(ran)
    end)

    it('should support variable package path', function()
        setconf {
            package_path = {
                'template/?.lua', 'template/?/init.lua',
                'funny_random_path/?.lua',
            }
        }
        putfile('funny_random_path/test.lua', function() return 5 end)
        helper.init()
        local result = xero.require('test')
        assert(result == 5)
        helper.update()
    end)

    it('should support lua_pre_entry_path', function()
        setconf { lua_pre_entry_path = 'my_pre.lua' }
        local ran = false
        putfile('my_pre.lua', function()
            ran = true
        end)
        assert(not ran)
        helper.init()
        assert(ran)
        helper.update()
    end)

    it('should support strict mode', function()
        setconf { strict = true }
        helper.init()
        helper.update()
    end)

    it('should enforce strict mode', function()
        setconf { strict = true }
        putfile('lua/mods.lua', function()
            my_global = 5
        end)
        helper.init()
        assert.errors(function()
            helper.update()
        end)
    end)

end)

