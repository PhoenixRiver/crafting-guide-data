#
# Crafting Guide Data - data.test.coffee
#
# Copyright (c) 2015-2017 by Redwood Labs
# All rights reserved.
#

CraftingGuideCommon = require "crafting-guide-common"
fs                  = require 'fs'

_                   = CraftingGuideCommon._
Mod                 = CraftingGuideCommon.deprecated.game.Mod
ModParser           = CraftingGuideCommon.deprecated.parsing.ModParser
ModVersion          = CraftingGuideCommon.deprecated.game.ModVersion
ModVersionParser    = CraftingGuideCommon.deprecated.parsing.ModVersionParser

########################################################################################################################

describe 'data files for', ->

    for modSlug in fs.readdirSync './data/'
        stats = fs.lstatSync "./data/#{modSlug}"
        continue unless stats.isDirectory()

        do (modSlug)->
            describe modSlug, ->

                mod = new Mod slug:modSlug
                modParser = new ModParser model:mod, showAllErrors:true
                try
                    modParser.parse fs.readFileSync "./data/#{modSlug}/mod.cg", 'utf8'
                catch
                    # Just a placeholder directory for a suggested mod.
                    return

                it 'loads mod.cg without errors', ->
                    (e.stack for e in modParser.errors).should.eql []
                    mod.name.should.not.equal ''
                    mod.activeModVersion.should.exist

                it 'has an icon file', ->
                    stats = fs.statSync "./data/#{modSlug}/icon.png"
                    stats.isFile().should.be.true

                mod.eachModVersion (modVersion)->
                    do (modVersion)->
                        describe modVersion.version, ->

                            modVersionParser = new ModVersionParser model:modVersion, showAllErrors:true
                            fileName = "./data/#{modSlug}/versions/#{modVersion.version}/mod-version.cg"
                            modVersionParser.parse fs.readFileSync fileName, 'utf8'

                            it 'loads mod-version.cg without errors', ->
                                modVersionParser.errors.should.eql []
                                _.keys(modVersion._items).length.should.be.greaterThan 0
                                _.keys(modVersion._recipes).length.should.be.greaterThan 0
