local utils = require('core.utils')

-- Move global functions to the xero table, allowing for slightly faster
-- performance due to not having to go back and forth between xero and _G.
xero.xero = _G.xero
xero.type = _G.type
xero.print = _G.print
xero.pairs = _G.pairs
xero.ipairs = _G.ipairs
xero.unpack = _G.unpack
xero.tonumber = _G.tonumber
xero.tostring = _G.tostring
xero.math = utils.copy(_G.math)
xero.table = utils.copy(_G.table)
xero.string = utils.copy(_G.string)
