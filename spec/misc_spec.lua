---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe(' things', function()

    before_each(function()
       helper.reset()
       helper.init()
    end)

    after_each(function()
        xero = nil
    end)

    it('', function()
        xero.acc{1, 100, 'bumpy'}
        update(0.5)
        assert.equal(nil, helper.get_mod('bumpy'))
        update(1)
        assert.equal('100', helper.get_mod('bumpy'))
    end)

    it('adds when called multiple times', function()
        xero.acc{1, 100, 'bumpy'}
        xero.acc{1, 100, 'bumpy'}
        xero.acc{1, 100, 'bumpy'}
        xero.acc{1, 100, 'bumpy'}
        xero.acc{1, 100, 'bumpy'}
        update(0.5)
        assert.equal(nil, helper.get_mod('bumpy'))
        update(1)
        assert.equal('500', helper.get_mod('bumpy'))
    end)

end)
