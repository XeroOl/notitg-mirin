---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('alias', function()

    before_each(function()
        helper.reset()
        helper.init()
    end)

    after_each(function()
        xero = nil
    end)

    it('should work with ease', function()
        xero.alias{'a', 'b'}
        pending()
    end)

end)
