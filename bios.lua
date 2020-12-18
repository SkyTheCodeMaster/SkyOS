_G.paintutils = require("libraries.apis.paintutils")
_G.file = require("libraries.file")
_G.graphic = require("libraries.file")
_G.pg = require("libraries.progressBar")
local graphic = require("libraries.graphic")
local file = require("libraries.file")
local pg = require("libraries.progressBar")
local x,y = term.getSize()
local dbFile = "data/main.skydb"
 
term.setBackgroundColour(colours.blue)
term.setTextColour(colours.white)
term.clear()
-- load variables into global environment
local dbHandle = fs.open(dbFile,"r")
_G.SkyOS = {}
local tData = textutils.unserialise(dbHandle.readAll())
_G.SkyOS = tData
dbHandle.close()
 
local mainMon = peripheral.wrap(SkyOS.monitors.main)
mainMon.setTextScale(0.5)
file.loadGrpLines("images/bootSplash.skgrp",mainMon)
local biosBar = pg.new(3,3,55,colours.lime,colours.grey,"biosBar",nil,mainMon)
 
graphic.drawBox(1,0,x,y-1,colours.white)
-- begin loading bg processes
shell.run("bg bg/timeserver.lua")
