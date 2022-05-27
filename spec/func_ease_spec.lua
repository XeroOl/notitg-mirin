---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('func_ease', function()

    before_each(function()
        helper.reset()
        helper.init()
    end)

    after_each(function()
        xero = nil
    end)

    it('should allow valid signatures', function()
        xero.a_function = function() end

        xero.func_ease {0, 1, xero.outExpo, function() end}
        xero.func_ease {0, 1, xero.outExpo, 'a_function'}
        xero.func_ease {0, 1, xero.outExpo, 10, function() end}
        xero.func_ease {0, 1, xero.outExpo, 10, 'a_function'}
        xero.func_ease {0, 1, xero.outExpo, 100, 0, function() end}
        xero.func_ease {0, 1, xero.outExpo, 100, 0, 'a_function'}
        for i = 1, 10 do
            update(0.1)
        end
    end)

    it('should support mode=', function()
        xero.func_ease{1, 2, xero.linear, function(p)
            assert.equal(p, 0.5)
        end, mode = 'end'}
        update(1.5)
    end)

    it('should persist', function()
        local last_set_1, last_set_2
        xero.obj = {}
        function xero.obj:fn1(p)
            last_set_1 = p
        end
        function xero.obj:fn2(p)
            last_set_2 = p
        end

        xero.func_ease {0, 1, xero.outExpo,  200, 'obj:fn1'}
        xero.func_ease {0, 1, xero.bell, 200, 'obj:fn2'}

        update(100)

        assert.equal(last_set_1, 200)
        assert.equal(last_set_2, 0)
    end)

end)
