---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('reset', function()

    before_each(function()
        helper.reset()
        helper.init()
    end)

    after_each(function()
        xero = nil
    end)

    it('resets the mods', function()
        xero.set {0,
            100, 'zigzag',
            100, 'tanspiralz',
            100, 'tanspiralzperiod',
            100, 'drawsize',
            100, 'bumpyx',
            100, 'drunk',
        }

        xero.reset {1}

        update(2)
        assert.equal('0', helper.get_mod('zigzag'))
        assert.equal('0', helper.get_mod('tanspiralz'))
        assert.equal('0', helper.get_mod('tanspiralzperiod'))
        assert.equal('0', helper.get_mod('drawsize'))
        assert.equal('0', helper.get_mod('bumpyx'))
        assert.equal('0', helper.get_mod('drunk'))
    end)

    it('skips mods with exclude=', function()
        xero.set {0,
            100, 'zigzag',
            100, 'tanspiralz',
            100, 'tanspiralzperiod',
            100, 'drawsize',
            100, 'bumpyx',
            100, 'drunk',
        }

        xero.reset {1, exclude = 'drawsize'}

        xero.set {3,
            100, 'zigzag',
            100, 'tanspiralz',
            100, 'tanspiralzperiod',
            100, 'drawsize',
            100, 'bumpyx',
            100, 'drunk',
        }

        xero.reset {4, exclude = {'drawsize', 'bumpyx'}}

        update(2)
        assert.equal('0', helper.get_mod('zigzag'))
        assert.equal('0', helper.get_mod('tanspiralz'))
        assert.equal('0', helper.get_mod('tanspiralzperiod'))
        assert.equal('100', helper.get_mod('drawsize'))
        assert.equal('0', helper.get_mod('bumpyx'))
        assert.equal('0', helper.get_mod('drunk'))
        update(3)
        assert.equal('0', helper.get_mod('zigzag'))
        assert.equal('0', helper.get_mod('tanspiralz'))
        assert.equal('0', helper.get_mod('tanspiralzperiod'))
        assert.equal('100', helper.get_mod('drawsize'))
        assert.equal('100', helper.get_mod('bumpyx'))
        assert.equal('0', helper.get_mod('drunk'))
    end)

    it('only resets mods provided to only=', function()
        xero.set {0,
            100, 'zigzag',
            100, 'tanspiralz',
            100, 'tanspiralzperiod',
            100, 'drawsize',
            100, 'bumpyx',
            100, 'drunk',
        }

        xero.reset {1, only = 'drawsize'}

        xero.set {3,
            100, 'zigzag',
            100, 'tanspiralz',
            100, 'tanspiralzperiod',
            100, 'drawsize',
            100, 'bumpyx',
            100, 'drunk',
        }

        xero.reset {4, only = {'drawsize', 'bumpyx'}}

        update(2)
        assert.equal('100', helper.get_mod('zigzag'))
        assert.equal('100', helper.get_mod('tanspiralz'))
        assert.equal('100', helper.get_mod('tanspiralzperiod'))
        assert.equal('0', helper.get_mod('drawsize'))
        assert.equal('100', helper.get_mod('bumpyx'))
        assert.equal('100', helper.get_mod('drunk'))
        update(3)
        assert.equal('100', helper.get_mod('zigzag'))
        assert.equal('100', helper.get_mod('tanspiralz'))
        assert.equal('100', helper.get_mod('tanspiralzperiod'))
        assert.equal('0', helper.get_mod('drawsize'))
        assert.equal('0', helper.get_mod('bumpyx'))
        assert.equal('100', helper.get_mod('drunk'))
    end)

    it('eases when an ease is provided', function()
        xero.set{0, 100, 'bumpyx'}
        xero.reset{1, 2, xero.linear}
        update(2)
        assert.equal('50', helper.get_mod('bumpyx'))
        update(1)
        assert.equal('0', helper.get_mod('bumpyx'))
    end)

    it('detects this bad signature', function()
        assert.errors(function() xero.reset{0, 1} end)
    end)

end)
