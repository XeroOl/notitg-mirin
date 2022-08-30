---@diagnostic disable: undefined-global
local helper = require('spec.helper')
local init = helper.init
local update = helper.update
local putfile = helper.putfile

describe('conf_options', function()

	before_each(function()
		helper.reset()
	end)

	after_each(function()
		xero = nil
	end)

	local function setconf(t)
		putfile('conf.lua', function() return t end)
	end

	it('should have default settings in the conf.lua', function()
		local conf = loadfile('conf.lua')()
		putfile('conf.lua', function() return {} end)
		helper.init()
		local defaults = xero.require('core.options')
		assert.same(defaults, conf)
	end)

	it('should support changing max_pn', function()
		helper.add_config_options {max_pn = 4}
		helper.init()
		local options = xero.require('core.options')
		assert(options.max_pn == 4)
		xero.set {1, 100, 'invert', plr = 5}
		update()
		assert(xero.P4)
		assert(not xero.P5)
		assert.is_nil(helper.get_mod('invert', 5))
	end)

	it('should support disabling the prelude', function()
		pending('hard')
	end)

	it('should support lua entry path', function()
		local ran = false
		helper.add_config_options {lua_entry_path = 'other_path.lua'}
		putfile('other_path.lua', function() ran = true end)
		putfile('lua/mods.lua', function() error('loaded the original') end)
		helper.init()
		helper.update()
		assert(ran)
	end)

	it('should support variable package path', function()
		helper.add_config_options {
			package_path = {
				'template/?.lua', 'template/?/init.lua',
				'funny_random_path/?.lua',
			}
		}
		putfile('funny_random_path/test.lua', function() return 5 end)
		helper.init()
		local result = xero.require('test')
		assert(result == 5)
		helper.update()
	end)

	it('should support lua_pre_entry_path', function()
		helper.add_config_options {lua_pre_entry_path = 'my_pre.lua'}
		local ran = false
		putfile('my_pre.lua', function()
			ran = true
		end)
		assert(not ran)
		helper.init()
		assert(ran)
		helper.update()
	end)

	it('should support strict mode', function()
		helper.add_config_options {strict = true}
		helper.init()
		helper.update()
		helper.update()
		helper.update()
	end)

	it('should enforce strict mode (disallow writing unknown globals)', function()
		helper.add_config_options {strict = true}
		putfile('lua/mods.lua', function()
			My_global = 5
		end)
		helper.init()
		assert.errors(function()
			helper.update()
		end)
	end)

	it('should enforce strict mode (disallow reading unknown globals)', function()
		helper.add_config_options {strict = true}
		putfile('lua/mods.lua', function()
			print(unknown_global_or_a_word_with_a_typo_in_it)
		end)
		helper.init()
		assert.errors(function()
			helper.update()
		end)
	end)

	it('should renumber the players if P1 is missing', function()
		for pn = 1, 7, 2 do
			helper.mock().delete_player(pn)
		end
		init()
		update()
		assert(xero.P1, 'missing P1')
		assert(xero.P2, 'missing P2')
		assert(xero.P3, 'missing P3')
		assert(xero.P4, 'missing P4')
		assert(not xero.P5, 'P5 should be gone')
		assert(not xero.P6, 'P6 should be gone')
		assert(not xero.P7, 'P7 should be gone')
		assert(not xero.P8, 'P8 should be gone')
		assert(xero.P[1], 'missing P[1]')
		assert(xero.P[2], 'missing P[2]')
		assert(xero.P[3], 'missing P[3]')
		assert(xero.P[4], 'missing P[4]')
		assert(not xero.P[5], 'P[5] should be gone')
		assert(not xero.P[6], 'P[6] should be gone')
		assert(not xero.P[7], 'P[7] should be gone')
		assert(not xero.P[8], 'P[8] should be gone')
		assert(xero.P1:GetInputPlayer() == 1)
		assert(xero.P2:GetInputPlayer() == 1)
	end)

	it('should renumber the players if P2 is missing', function()
		for pn = 2, 8, 2 do
			helper.mock().delete_player(pn)
		end
		init()
		update()
		assert(xero.P1, 'missing P1')
		assert(xero.P2, 'missing P2')
		assert(xero.P3, 'missing P3')
		assert(xero.P4, 'missing P4')
		assert(not xero.P5, 'P5 should be gone')
		assert(not xero.P6, 'P6 should be gone')
		assert(not xero.P7, 'P7 should be gone')
		assert(not xero.P8, 'P8 should be gone')
		assert(xero.P[1], 'missing P[1]')
		assert(xero.P[2], 'missing P[2]')
		assert(xero.P[3], 'missing P[3]')
		assert(xero.P[4], 'missing P[4]')
		assert(not xero.P[5], 'P[5] should be gone')
		assert(not xero.P[6], 'P[6] should be gone')
		assert(not xero.P[7], 'P[7] should be gone')
		assert(not xero.P[8], 'P[8] should be gone')
		assert(xero.P1:GetInputPlayer() == 0)
		assert(xero.P2:GetInputPlayer() == 0)
	end)

	local function check_players(correct_input_players)
		for i = 1, #correct_input_players do
			assert.equal(correct_input_players[i], xero.P[i]:GetInputPlayer())
		end
	end

	it('should set up player control by default', function()
		init()
		update()
		check_players {0, 1, 0, 1, 0, 1, 0, 1}
	end)

	it('Configuration should change the player inputs', function()
		helper.add_config_options {
			inputs = {
				[1] = 'P1', [2] = 'P2',
				[3] = 'AUTO', [4] = 'P2',
				[5] = 'AUTO', [6] = 'AUTO',
				[7] = 'P2', [8] = 'P1',
			},
		}
		init()
		update()
		check_players {0, 1, 2, 1, 2, 2, 1, 0}
	end)

	it('it should reassign the input players based on the conf', function()
		helper.add_config_options {
			max_pn = 4,
			inputs = {'P1', 'AUTO', 'P2', 'AUTO'},
		}
		for pn = 2, 8, 2 do
			helper.mock().delete_player(pn)
		end
		init()
		update()
		assert(xero.P1, 'missing P1')
		assert(xero.P2, 'missing P2')
		assert(xero.P3, 'missing P3')
		assert(xero.P4, 'missing P4')
		assert(not xero.P5, 'P5 should be gone')
		assert(not xero.P6, 'P6 should be gone')
		assert(not xero.P7, 'P7 should be gone')
		assert(not xero.P8, 'P8 should be gone')
		assert(xero.P[1], 'missing P[1]')
		assert(xero.P[2], 'missing P[2]')
		assert(xero.P[3], 'missing P[3]')
		assert(xero.P[4], 'missing P[4]')
		assert(not xero.P[5], 'P[5] should be gone')
		assert(not xero.P[6], 'P[6] should be gone')
		assert(not xero.P[7], 'P[7] should be gone')
		assert(not xero.P[8], 'P[8] should be gone')
		assert.equal(0, xero.P1:GetInputPlayer())
		assert.equal(2, xero.P2:GetInputPlayer())
		assert.equal(0, xero.P3:GetInputPlayer())
		assert.equal(2, xero.P4:GetInputPlayer())
	end)

end)
