---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('func', function()

    before_each(function() helper.reset(); helper.init() end)
    after_each(function() xero = nil end)

    it('should run things in order', function()
        -- beat order
        -- tiebreaker is order func was called
        -- defer=true means to pick to run later in the tiebreaker
        local order = 0
        local func = xero.func
        func {5, function() assert.equals(order, 0) order = 1 end}
        func {7, function() assert.equals(order, 2) order = 3 end}
        func {7, function() assert.equals(order, 5) order = 6 end, defer = true}
        func {6, function() assert.equals(order, 1) order = 2 end}
        func {7, function() assert.equals(order, 4) order = 5 end, defer = true}
        func {7, function() assert.equals(order, 3) order = 4 end}
        update(10)
        assert.equals(order, 6)
    end)
    it('shouldn\'t run early', function()
        xero.func {100, function()
            assert(false, 'you ran the func')
        end}
        update(99.99)
    end)
    it('should support everything eater (even though it\'s terrible)', function()
        local runs = false
        function xero.global(a, b)
            assert.equals(a, 100)
            assert.equals(b, 'hello')
            runs = true
        end
        xero.func {5, 'global', 100, 'hello'}
        update(4)
        assert(not runs)
        update(4)
        assert(runs)
    end)

    it('should support delay=', function()
        pending()
    end)

    it('should have proper persist semantics', function()
        local count = 0
        local function no()
            assert(false, 'this shouldn\'t have run')
        end
        local function yes()
            assert(true, 'this should run')
            count = count + 1
        end
        -- frame is on beat 5.75
        xero.func {0, no, persist = false}
        xero.func {0.5, no, persist = false}
        xero.func {0, no, persist = 5}
        xero.func {2, no, persist = 3}
        xero.func {3, no, persist = 5, mode = 'end'}
        xero.func {0, yes, persist = 6}
        xero.func {2, yes, persist = 4}
        xero.func {0, yes, persist = true}
        xero.func {3, yes, persist = 6.5, mode = 'end'}
        update(5.75)

        assert.equal(4, count, 'Not all persists persisted')
    end)
end)
