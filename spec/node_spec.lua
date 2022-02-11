---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local update = helper.update

describe('node', function()

    before_each(function()
        helper.reset()
        helper.init()
    end)

    after_each(function()
        xero = nil
    end)

    -- TODO

end)
