local function path(file)
  if LevelOS then
    return fs.combine(fs.getDir(LevelOS.self.window.path),file)
  elseif PhileOS then
    return fs.combine(fs.getDir(shell.getRunningProgram()),file)
  else
    return fs.combine(shell.dir(),file)
  end 
end

-- Load cache data, or return empty table if none.
local f = fs.open("SkyOS/data.cfg","r")
local cache
if not f then cache = {badStarts=0} else cache = textutils.unserialize(f.readAll()) f.close() end

if cache.badStarts >= 3 then -- We've had problems booting. Load button and skimg to enable crash menu.
  local button = require("libraries.button")
  local skimg = require("libraries.skimg")
  local recovery = skimg("graphics/recovery.skimg") -- Load the skimg
  recovery() -- Draw the skimg.
  local shellButton,bootButton
  local function toShell()
    term.setTextColour(colours.white) 
    term.setBackgroundColour(colours.blue) 
    term.clear() 
    term.setCursorPos(1,1)
    error("Emergency SkyOS Shell") 
  end
  local function boot()
    cache.badStarts = 0
    local f = fs.open("SkyOS/data.cfg","w") f.write(textutils.serialize(cache)) f.close()
    os.reboot()
  end
  shellButton = button.newButton(5,10,15,3,toShell)
  bootButton = button.newButton(5,15,15,3,boot)
  while true do
    local e = {os.pullEvent()}
    if e[1] == "char" then
      if e[2] == "e" then
        toShell()
      elseif e[2] == "c" then
        boot()
      end
    elseif e[1] == "mouse_click" then
      button.executeButtons(e)
    end
  end
end
-- Put stuffs in path lol
package.path = package.path .. ";libraries/?;libraries/?.lua"

local log = require("libraries.log")
-- normal loading
term.clear()
term.setCursorPos(1,1)
_G.SkyOS = {}
_G.SkyOS.buttons = {}
_G.SkyOS.settings = require("settings.general")
_G.SkyOS.emu = {}
_G.SkyOS.wins = {}
_G.SkyOS.version = "21.06.0"
_G.SkyOS.data = {
  heldKeys = {},
  selectedScreen = 1,
  homeScreenOpen = true,
  event = {}
}
_G.SkyOS.coro = require("libraries.coro")
_G.SkyOS.displayError = function(msg)
  term.setBackgroundColour(colours.blue)
  term.setTextColour(colours.white)
  term.clear()
  term.setCursorPos(1,1)
  term.write("SkyOS encountered an error")
  term.setCursorPos(1,2)
  term.write("Press any key to reboot.")
  term.setCursorPos(1,3)
  print(msg)
  os.pullEvent("key")
  if os.clock() < 30 then -- This is close enough to be startup, 30 seconds is fine.
    cache.badStarts = cache.badStarts + 1
  end
  local f = fs.open("SkyOS/data.cfg","w")
  f.write(textutils.serialize(cache))
  f.close()
  os.reboot()
end

local mainLog = log.create("logs/main.sklog")
mainLog:info("SkyOS")
mainLog:info("Contact:")
mainLog:info("Github: SkyTheCodeMaster, Discord: SkyCrafter0#6386")
mainLog:info("Discord: https://discord.gg/cY7r2Mt7tc")
mainLog:info("Checking for emulation...")

SkyOS.emu.levelos = (lOS and lUtils) and true or false
SkyOS.emu.craftospc = (periphemu and config) and true or false
SkyOS.emu.ccemux = (ccemux) and true or false
SkyOS.emu.phileos = (PhileOS) and true or false

mainLog:info("LevelOS: " .. tostring(SkyOS.emu.levelos))
mainLog:info("CraftOS-PC: " .. tostring(SkyOS.emu.craftospc))
mainLog:info("CCEmuX: " .. tostring(SkyOS.emu.ccemux))
mainLog:info("PhileOS: " .. tostring(SkyOS.emu.phileos))

if SkyOS.emu.levelos then
  mainLog:info("Running LevelOS-specific functions")
  local x,y = LevelOS.self.window.win.getPosition()
  LevelOS.self.window.win.reposition(x,y,26,20)
  LevelOS.self.window.resizable = false
  LevelOS.self.window.title = "SkyOS v21.04"
end
if SkyOS.emu.phileos then
  mainLog:info("Running PhileOS-specific functions")
  local id = PhileOS.ID
  PhileOS.setSize(id,26,20)
  PhileOS.setName(id,"SkyOS v21.04")
  PhileOS.setCanResize(id,false)
end

-- Quickload boot splash by utilizing the mini skimg library.
local skimg = require("libraries.skimg")
local bootSplash = skimg.load("graphics/bootSplash.skimg")
skimg.draw(bootSplash)
skimg = nil

-- Load all the libraries that haven't been loaded. This also caches them into `require` so it's faster for other programs to load them.
local progressBar = require("libraries.progressBar")
local ec25519 = require("libraries.ec25519")
local sUtils = require("libraries.sUtils")
local sos = require("libraries.sos")
local button = require("libraries.button")


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
  local time
  if SkyOS.settings.useRealtime then
    local timetable = sUtils.getTime(SkyOS.settings.timeZone)
    local strmin = tostring(timetable.min)
    local strhour = tostring(timetable.hour)
    if strmin:len() == 1 then
      strmin = "0" .. strmin
    end
    if strhour:len() == 1 then
      strhour = "0" .. strhour
    end
    time = strhour .. ":" .. strmin
  else
    time = textutils.formatTime(os.time("ingame"),true)
  end
  if time:len() == 4 then time = "0" .. time end
  term.setCursorPos(x,y)
  term.setBackgroundColour(backColour)
  term.setTextColour(textColour)
  term.write(time)
end

local function drawHomescreen()
  local desktopImg = sUtils.asset.load(path(SkyOS.settings.desktopImg))
  local taskbarImg = sUtils.asset.load(path(SkyOS.settings.taskbarImg))
  local notifbarImg = sUtils.asset.load(path(SkyOS.settings.notifbarImg))
  sUtils.asset.drawSkimg(desktopImg,1,2)
  sUtils.asset.drawSkimg(taskbarImg,1,20)
  sUtils.asset.drawSkimg(notifbarImg)
end

drawHomescreen()

local function main()
  while true do
    -- Draw the time
    drawTime(1,1,colours.grey,colours.white)
    -- Handle screenshots
    if SkyOS.data.heldKeys[keys.leftCtrl] and SkyOS.data.heldKeys[keys.leftShift] and SkyOS.data.heldKeys[keys.p] then
      sos.screenshot()
    end
    os.queueEvent("mainYield")
    coroutine.yield()
  end
end

local function eventMan()
  while true do
    SkyOS.data.event = {coroutine.yield()}
    local event = SkyOS.data.event
    if event[1] == "mouse_click" or event[1] == "mouse_drag" then
      button.executeButtons(event,true)
    elseif event[1] == "key" then
      SkyOS.data.heldKeys[event[2]] = true
        if event[2] == keys.e then
          mainLog:info("E pressed, exiting to SkyShell")
          mainLog:save()
          term.setBackgroundColour(colours.black)
          term.clear()
          term.setCursorPos(1,1)
          SkyOS.coro.stop()
        end
    elseif event[1] == "key_up" then
      SkyOS.data.heldKeys[event[2]] = false
    end
  end
end

SkyOS.coro.newCoro(main,"SkyOS") -- This is the main loop for skyos, it is important.
SkyOS.coro.newCoro(eventMan,"Event Manager") -- This manages events for SkyOS, it is important.
SkyOS.coro.runCoros()
 
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
  if sLine == "update" then
    sos.updateSkyOS()
  else
    if sLine:match("%S") and tCommandHistory[#tCommandHistory] ~= sLine then
      table.insert(tCommandHistory, sLine)
    end
    shell.run(sLine)
  end
end
