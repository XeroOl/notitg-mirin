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

    -- TODO

end)
