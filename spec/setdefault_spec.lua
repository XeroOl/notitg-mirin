---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('setdefault', function()

    before_each(function()
        helper.reset()
        helper.init()
    end)

    after_each(function()
        xero = nil
    end)

    it('should work', function()
        xero.setdefault {100, 'invert'}
        helper.update(1)
        assert.equal("100", helper.get_mod('invert'))
    end)

    it('should take the last result', function()
        xero.setdefault {100, 'invert'}
        xero.setdefault {200, 'invert'}
        helper.update(1)
        assert.equal("200", helper.get_mod('invert'))
    end)
end)
