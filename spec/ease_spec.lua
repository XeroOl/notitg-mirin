---@diagnostic disable: undefined-global
local helper = require 'spec.helper'
local update = helper.update

describe('ease', function()

    before_each(function() helper.reset(); helper.init() end)
    after_each(function() xero = nil end)

    it('should be callable', function()
        xero.ease {0, 1, xero.outExpo, 100, 'invert'}
    end)
    it('should ease the value', function()
        xero.ease {0, 1, xero.outExpo, 10000, 'bumpy'}
        for _ = 1, 30 do update(1/60) end
        assert.equal(tostring(xero.outExpo(.5) * 10000), helper.get_mod('bumpy'))
        for _ = 1, 30 do update(1/60) end
       assert.equal(tostring(10000), helper.get_mod('bumpy'))
    end)
    it('should work with specific players', function()
        xero.ease {0, 1, xero.outExpo, 100, 'invert', plr = 1}
        xero.ease {0, 1, xero.outExpo, -100, 'invert', plr = 2}
        xero.ease {2, 1, xero.outExpo, 0, 'invert'}
        update(1)
        assert.equal(tostring(100), helper.get_mod('invert', 1))
        assert.equal(tostring(-100), helper.get_mod('invert', 2))
        update(2)
        assert.equal(tostring(0), helper.get_mod('invert', 1))
        assert.equal(tostring(0), helper.get_mod('invert', 2))
    end)
    it('should add eases', function()
        xero.ease {0, 1, xero.outExpo, 10000, 'bumpy'}
        xero.ease {0.5, 1, xero.outExpo, 3000, 'bumpy'}
        for _ = 1, 30 do update(1/60) end
        assert.equal(tostring(xero.outExpo(.5) * 10000), helper.get_mod('bumpy'))
        for _ = 1, 30 do update(1/60) end
        assert.equal(tostring(10000 - xero.outExpo(.5) * 7000), helper.get_mod('bumpy'))
        for _ = 1, 30 do update(1/60) end
        assert.equal(tostring(3000), helper.get_mod('bumpy'))
    end)
    it('should prioritize most recently called ease', function()
        xero.ease {0, 1, xero.outExpo, 100, 'dizzy'}
        xero.ease {0, 4, xero.outExpo, 400, 'dizzy'}
        xero.ease {0, 8, xero.outExpo, 800, 'dizzy'}
        xero.ease {0, 6, xero.outExpo, 600, 'dizzy'}
        xero.ease {0, 2, xero.outExpo, 200, 'dizzy'}
        xero.ease {0, 9, xero.outExpo, 900, 'dizzy'}
        xero.ease {0, 3, xero.outExpo, 300, 'dizzy'}
        xero.ease {0, 5, xero.outExpo, 500, 'dizzy'}
        xero.ease {0, 8, xero.outExpo, 800, 'dizzy'}
        update(10) -- 10 beats later
        assert.equal('800', helper.get_mod('dizzy'))
    end)
    it('should require curly braces', function()
        assert.errors(function() xero.ease('haha, no curly') end)
    end)
    it('should detect missing beats', function()
        assert.errors(function() xero.ease{nil, 1, xero.outExpo, 100, 'invert'} end)
    end)
    it('should detect missing length', function()
        assert.errors(function() xero.ease{0, nil, xero.outExpo, 100, 'invert'} end)
    end)
    it('should detect bad ease functions', function()
        assert.errors(function() xero.ease{0, 1, function()end, 100, 'invert'} end)
    end)
    it('should detect nil mod magnitudes', function()
        assert.errors(function() xero.ease{0, 1, xero.outExpo, nil, 'invert'} end)
    end)
    it('should detect bad mod magnitudes', function()
        assert.errors(function() xero.ease{0, 1, xero.outExpo, {100}, 'invert'} end)
    end)
    it('should detect bad mod names (case 1)', function()
        assert.errors(function()
            -- tricky comma
            xero.ease{0, 1, xero.outExpo, 100, 'invert,'}
            update()
        end)
    end)
    it('should detect bad mod names (case 2)', function()
        assert.errors(function()
            xero.ease{0, 1, xero.outExpo, 100, '1.2x'}
            update()
        end)
    end)
    it('should detect bad mod names (case 3)', function()
        assert.errors(function()
            xero.ease{0, 1, xero.outExpo, 100, 'c500'}
            update()
        end)
    end)
    it('should detect missing mod names', function()
        assert.errors(function() xero.ease{0, 1, xero.outExpo, 100, nil} end)
    end)
    it('should get mad at bad plr', function()
        assert.errors(function() xero.ease{0, 1, xero.outExpo, 100, 'dizzy', plr = '1'} end)
    end)
    it('should have mode=end work right', function()
        xero.ease {10, 5, xero.outExpo, 100, 'movex0'}
        xero.ease {10, 15, xero.outExpo, 100, 'movex1', mode = 'end'}
        xero.ease {10, 15, xero.outExpo, 100, 'movex2', m = 'e'}
        xero.ease {4, 5, xero.inExpo, 100, 'movex3', mode = 'end'}
        update(5)
        assert.equal('100', helper.get_mod('movex3'))
        update(5)
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex1'))
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex2'))
        update(1)
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex1'))
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex2'))
        update(1)
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex1'))
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex2'))
        update(1)
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex1'))
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex2'))
        update(1)
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex1'))
        assert.equal(helper.get_mod('movex0'), helper.get_mod('movex2'))
    end)
end)
