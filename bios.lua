_G.paintutils = require("libraries.apis.paintutils")
_G.file = require("libraries.file")
_G.graphic = require("libraries.graphic")
_G.pg = require("libraries.pg")
_G.pga = require("libraries.pgAdvanced")
local graphic = require("libraries.graphic")
local file = require("libraries.file")
local completion = require("cc.shell.completion")
local pg = require("libraries.pg")
local pga = require("libraries.pgAdvanced")
local x,y = term.getSize()
local dbFile = "data/main.skydb"
 
-- shell colours
local bgColour = colours.blue
local promptColour = colours.yellow
local textColour = colours.white
 
term.setBackgroundColour(colours.blue)
term.setTextColour(colours.white)
term.clear()
 
-- Initialize completion for programs
-- edit
 
local complete = completion.build( {completion.file} )
shell.setCompletionFunction("edit.lua",complete)
 
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
graphic.drawBox(2,5,56,7,256,mainMon)
local bgBar = pg.new(3,5,55,colours.lime,colours.grey,"bgBar",nil,mainMon)
-- begin loading bg processes
local biosSteps = {
  "Loading Background Processes",
  "Loading Shell               ",
}
 
local bgSteps = {
  "Timeserver  ",
  "GPS Server  ",
  "Turtleserver",
  "Krist Viewer",
}
 
local aBiosBar = pga.create(biosBar,#biosSteps,biosSteps,1)
local aBG = pga.create(bgBar,#bgSteps,bgSteps,1)
 
pga.update(aBiosBar,1)
pga.update(aBG,1)
shell.run("bg bg/timeserver.lua")
pga.update(aBG,2)
shell.run("bg bg/gps host -67 61 7")
pga.update(aBG,3)
shell.run("bg bg/turtleserver.lua")
pga.update(aBG,4)
shell.run("bg bg/kstviewer.lua")
pg.update(bgBar,100)
file.loadGrpLines("images/bgBarPatch.skgrp",mainMon)
-- custom shell
 
pga.update(aBiosBar,2)
term.setCursorPos(1,1)
term.setBackgroundColor(bgColour)
term.setTextColour(promptColour)
print(os.version())
term.setTextColour(textColour)
 
-- Read commands and execute them
local tCommandHistory = {}
pg.update(biosBar,100)
file.loadGrpLines("images/pgPatch.skgrp",mainMon)
while true do
  term.setBackgroundColor(bgColour)
  term.setTextColour(promptColour)
  write(shell.dir() .. "> ")
  term.setTextColour(textColour)
 
  local sLine
  if settings.get("shell.autocomplete") then
    sLine = read(nil, tCommandHistory, shell.complete)
  else
    sLine = read(nil, tCommandHistory)
  end
  table.insert(tCommandHistory, sLine)
  shell.run(sLine)
end
