---@diagnostic disable: undefined-global
local helper = require 'spec.helper'
local update = helper.update

describe('extra.card', function()

	local Song, SetNumSpellCards, SetSpellCardTiming, SetSpellCardName, SetSpellCardDifficulty, SetSpellCardColor
	before_each(function()
		helper.reset()
		helper.init()
		Song = GAMESTATE:GetCurrentSong()

		SetNumSpellCards = stub(Song, "SetNumSpellCards")
		SetSpellCardTiming = stub(Song, "SetSpellCardTiming")
		SetSpellCardName = stub(Song, "SetSpellCardName")
		SetSpellCardDifficulty = stub(Song, "SetSpellCardDifficulty")
		SetSpellCardColor = stub(Song, "SetSpellCardColor")
	end)

	after_each(function()
		xero = nil
	end)

	it('should load up a spellcard', function()
		local card = xero.require('extra.card')
		card {0, 10, 'Example Name', 5, '#ccffcc'}
		update()

		assert.stub(SetNumSpellCards).was.called_with(Song, 1)
		assert.stub(SetSpellCardTiming).was.called_with(Song, 0, 0, 10)
		assert.stub(SetSpellCardName).was.called_with(Song, 0, 'Example Name')
		assert.stub(SetSpellCardDifficulty).was.called_with(Song, 0, 5)
		assert.stub(SetSpellCardColor).was.called_with(Song, 0, 204 / 255, 1, 204 / 255, 1)
	end)

	it('should load two spellcards', function()
		local card = xero.require('extra.card')
		card {0, 10, 'Example Name', 5, '#ccffcc'}
		card {10, 20, 'Name2', 2, {0.5, 0.25, 0.75, 1}}
		update()

		assert.stub(SetNumSpellCards).was.called_with(Song, 2)
		assert.stub(SetSpellCardTiming).was.called_with(Song, 0, 0, 10)
		assert.stub(SetSpellCardName).was.called_with(Song, 0, 'Example Name')
		assert.stub(SetSpellCardDifficulty).was.called_with(Song, 0, 5)
		assert.stub(SetSpellCardColor).was.called_with(Song, 0, 204 / 255, 1, 204 / 255, 1)
		assert.stub(SetSpellCardTiming).was.called_with(Song, 1, 10, 20)
		assert.stub(SetSpellCardName).was.called_with(Song, 1, 'Name2')
		assert.stub(SetSpellCardDifficulty).was.called_with(Song, 1, 2)
		assert.stub(SetSpellCardColor).was.called_with(Song, 1, 0.5, 0.25, .75, 1)
	end)
end)
