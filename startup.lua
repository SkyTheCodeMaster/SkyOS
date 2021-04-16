local function path(file)
  if LevelOS then
    return fs.combine(fs.getDir(LevelOS.self.window.path),file)
  else
    return fs.combine(shell.dir(),file)
  end 
end
-- replace apis with new ones
_G.paintutils = require("libraries.apis.paintutils")
local log = require("libraries.log")
-- normal loading
term.clear()
term.setCursorPos(1,1)
_G.SkyOS = {}
_G.SkyOS.buttons = {}
_G.SkyOS.settings = require("settings.general")
_G.SkyOS.emu = {}

local mainLog = log.create("logs/main.sklog")
mainLog:info("SkyOS")
mainLog:info("Contact:")
mainLog:info("Discord: https://discord.gg/cY7r2Mt7tc")
mainLog:info("Checking for emulation...")

SkyOS.emu.levelos = (lOS and lUtils) and true or false
SkyOS.emu.craftospc = (periphemu and config) and true or false
SkyOS.emu.ccemux = (ccemux) and true or false

mainLog:info("LevelOS: " .. tostring(SkyOS.emu.levelos))
mainLog:info("CraftOS-PC: " .. tostring(SkyOS.emu.craftospc))
mainLog:info("CCEmuX: " .. tostring(SkyOS.emu.ccemux))

if SkyOS.emu.levelos then
  mainLog:info("Running LevelOS-specific functions")
  local x,y = LevelOS.self.window.win.getPosition()
  LevelOS.self.window.win.reposition(x,y,26,20)
  LevelOS.self.window.resizable = false
  LevelOS.self.window.title = "SkyOS v" .. SkyOS.versions.OSVERSION
end

-- Quickload boot splash by utilizing the mini skimg library.
local skimg = require("libraries.skimg")
local bootSplash = skimg.load("graphics/bootSplash.skimg")
skimg.draw(bootSplash)
skimg = nil

-- Load all the libraries that haven't been loaded. This also caches them into `require` so it's faster for other programs to load them.
local progressBar = require("libraries.progressBar")
local ec25519 = require("libraries.ec25519")
local wireless = require("libraries.wireless")
local sUtils = require("libraries.sUtils")
local sos = require("libraries.sos")


--[[if fs.exists(path("beta.skprg")) then
    SkyOS.sLog.info("Beta version of SkyOS, pausing 1 second to emulate server comms")
    sleep(1)
end]]

mainLog:save()
--Do server side things BEFORE term.clear()

term.setBackgroundColour(colours.black)
--Begin auto version check

term.clear()

--Load DE

local function drawTime(x,y,backColour,textColour)
  local time = textutils.formatTime(os.date("ingame"),true)
  if time:len() == 4 then time = "0" .. time end
  term.setCursorPos(x,y)
  term.setBackgroundColour(backColour)
  term.setTextColour(textColour)
  term.write(time)
end

local function drawDesktop()
  local desktopImg = sUtils.asset.load(path(SkyOS.settings.desktopImg))
  local taskbarImg = sUtils.asset.load(path(SkyOS.settings.taskbarImg))
  sUtils.asset.drawSkimg(desktopImg)
  sUtils.asset.drawSkimg(taskbarImg,1,18)
end

drawDesktop()

local function main()
  while true do
    term.setCursorPos(22,20)
    term.write("     ")
    drawTime(22,20,colours.lightGrey,colours.white)
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
    mainLog:info("E pressed, exiting to SkyShell")
    mainLog:save()
    term.setBackgroundColour(colours.black)
    term.clear()
    term.setCursorPos(1,1)
  end,
  [keys.u] = function()
    mainLog:warn("U pressed, updating SkyOS")
    mainLog:save()
    term.clear()
    term.setCursorPos(1,1)
    sos.updateSkyOS(true)
  end
}
local function keyman()
  while true do
    local _, key = os.pullEvent("key")
    mainLog:info("GUI character pressed: " .. keys.getName(key))
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
print("SkyShell v21.04")
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
