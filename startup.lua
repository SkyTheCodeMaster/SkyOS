local function path(file)
  if LevelOS then
    return fs.combine(fs.getDir(LevelOS.self.window.path),file)
  else
    return fs.combine(shell.dir(),file)
  end 
end
-- replace apis with new ones
_G.paintutils = require("libraries.apis.paintutils")
-- normal loading
term.clear()
term.setCursorPos(1,1)
_G.SkyOS = {}
_G.SkyOS.sLog = require("libraries.log")
_G.SkyOS.buttons = {}
_G.SkyOS.versions = require("versions")
_G.SkyOS.settings = {}
_G.SkyOS.settings.timeZone = require("settings.general").timeZone
_G.SkyOS.settings.language = require("settings.general").language
_G.SkyOS.lib = {}
_G.SkyOS.emu = {}
_G.SkyOS.update = function() shell.run(path("wipeSkyOS.lua")) end
SkyOS.sLog.new("logs/mainLog.sklog","mainLog")
SkyOS.sLog.setMain("mainLog")
SkyOS.sLog.info("------------------------")
SkyOS.sLog.info("SkyOS Main Boot Sequence")
SkyOS.sLog.info("SkyOS V"..SkyOS.versions.OSVERSION)
SkyOS.sLog.info("Checking for emulators")

SkyOS.emu.levelos = (lOS and lUtils) and true or false
SkyOS.emu.craftospc = (periphemu and config) and true or false
SkyOS.emu.ccemux = (ccemux) and true or false

SkyOS.sLog.info("LevelOS: " .. tostring(SkyOS.emu.levelos))
SkyOS.sLog.info("CraftOS-PC: " .. tostring(SkyOS.emu.craftospc))
SkyOS.sLog.info("CCEmuX: " .. tostring(SkyOS.emu.ccemux))

if SkyOS.emu.levelos then
  SkyOS.sLog.info("Running LevelOS-specific functions")
  local x,y = LevelOS.self.window.win.getPosition()
  LevelOS.self.window.win.reposition(x,y,26,20)
  LevelOS.self.window.resizable = false
  LevelOS.self.window.title = "SkyOS v" .. SkyOS.versions.OSVERSION
end

SkyOS.sLog.info("Loading file lib")
SkyOS.lib.file = require("libraries.file")
if SkyOS.lib.file == nil then SkyOS.sLog.errorC(301,"file library does not exist, reinstall") else SkyOS.sLog.info("file lib loaded") end

SkyOS.sLog.info("Loading graphic lib")
SkyOS.lib.graphic = require("libraries.graphic")
if SkyOS.lib.graphic == nil then SkyOS.sLog.errorC(302,"graphic library does not exist, reinstall") else SkyOS.sLog.info("graphic lib loaded") end

SkyOS.lib.file.loadGrpLines(path("/graphics/bootSplash.skgrp"))

SkyOS.sLog.info("Loading gpswrapper lib")
SkyOS.lib.gpswrapper = require("libraries.gpswrapper")
if SkyOS.lib.gpswrapper == nil then SkyOS.sLog.errorC(303,"gpswrapper library does not exist, reinstall") else SkyOS.sLog.info("gpswrapper lib loaded") end

SkyOS.lib.ts = require("libraries.ts")
if SkyOS.lib.ts == nil then SkyOS.sLog.errorC(304,"ts library does not exist, reinstall") else SkyOS.sLog.info("ts lib loaded") end

--[[if fs.exists(path("beta.skprg")) then
    SkyOS.sLog.info("Beta version of SkyOS, pausing 1 second to emulate server comms")
    sleep(1)
end]]

SkyOS.sLog.save()
--Do server side things BEFORE term.clear()

term.setBackgroundColour(colours.black)
--Begin auto version check

term.clear()

--Load DE

local function drawTime(x,y,backColour,textColour)
  if SkyOS.lib.ts == nil then return "" end
  local time = SkyOS.lib.ts.get(SkyOS.settings.timeZone)[3]
  term.setCursorPos(x,y)
  term.setBackgroundColour(backColour)
  term.setTextColour(textColour)
  term.write(time)
end

local function drawDesktop()
  local desktopImg = path("graphics/background/default.skgrp")
  local taskbarImg = path("graphics/taskbar.skgrp")
  SkyOS.lib.file.loadGrpLines(desktopImg)
  SkyOS.lib.file.loadGrpLines(taskbarImg)
end

drawDesktop()

local function main()
  while true do
    term.setCursorPos(22,20)
    term.write("     ")
    drawTime(22,20,128,256)
    sleep()
  end
end

local function checkSizeLogs()
  while true do
    local curSize = file.getSize(path("./logs"))
    if curSize > 98304 then
      SkyOS.sLog.warn("log folder size is too large, transmitting and deleting logs.")
      SkyOS.sLog.close()
      fs.delete("./logs")
    end
    sleep(180)
  end
end

local keyTable = {
  [keys.e] = function()
    SkyOS.sLog.info("E pressed, exiting to SkyShell")
    SkyOS.sLog.save()
    term.setBackgroundColour(colours.black)
    term.clear()
    term.setCursorPos(1,1)
  end,
  [keys.u] = function()
    SkyOS.sLog.warn("U pressed, updating SkyOS")
    SkyOS.sLog.save()
    term.clear()
    term.setCursorPos(1,1)
    SkyOS.update()
  end
}
local function keyman()
  while true do
    local _, key = os.pullEvent("key")
    SkyOS.sLog.info("GUI character pressed: " .. keys.getName(key))
    if keyTable[key] then return keyTable[key]() end
  end
end
parallel.waitForAny(main,keyman)
 
-- Colours
local promptColour  = colours.yellow
local textColour = colours.white
local bgColour = colours.blue

term.setBackgroundColor(bgColour)
term.clear()
term.setTextColour(promptColour)
print("SkyShell V" .. SkyOS.versions.SHELLVERSION)
term.setTextColour(textColour)
 
-- Read commands and execute them
local tCommandHistory = {}
while true do
  term.setBackgroundColor(bgColour)
  term.setTextColour(promptColour)
  write(shell.dir() .. ":S> ")
  term.setTextColour(textColour)
  local sLine
  if settings.get("shell.autocomplete") then
    sLine = read(nil, tCommandHistory, shell.complete)
  else
    sLine = read(nil, tCommandHistory)
  end
  if sLine:match("%S") and tCommandHistory[#tCommandHistory] ~= sLine then
    table.insert(tCommandHistory, sLine)
  end
  shell.run(sLine)
end
