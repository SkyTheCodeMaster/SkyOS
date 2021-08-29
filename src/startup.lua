-- Top Level Coroutine Override. This disables the rednet thread from running, allowing enable/disable inside SkyOS.
if not oldShutdown then
  _G.oldShutdown = os.shutdown
  os.shutdown = function() os.run({},"rom/programs/shell.lua") end
  local i = 0
  repeat i = i + 1 until debug.getupvalue(rednet.run,i) == "bRunning" -- Thanks wojbie for showing this amazing use of debug. rednet sux:tm:
  debug.setupvalue(rednet.run,i,false) -- This kills the rednet coroutine, stopping the `parallel.waitForAny`, pcall returns ok, therefore the `press any key to continue` never shows up, it triggers the `os.shutdown()`, runs the custom one which runs a shell, which in turn runs startup file again.
else
  os.shutdown = oldShutdown -- Restore the real shutdown
  ---@diagnostic disable-next-line: lowercase-global 
  oldShutdown = nil -- Delete the old shutdown, leading to no _G pollution.
end

if SkyOS then
  error("SkyOS is already running.")
end

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
  local recovery = skimg(path("graphics/recovery.skimg")) -- Load the skimg
  recovery() -- Draw the skimg.
  local function toShell()
    term.setTextColour(colours.white) 
    term.setBackgroundColour(colours.blue) 
    term.clear() 
    term.setCursorPos(1,1)
    error("Emergency SkyOS Shell",0) 
  end
  local function boot()
    cache.badStarts = 0
    local f = fs.open("SkyOS/data.cfg","w") f.write(textutils.serialize(cache)) f.close()
    os.reboot()
  end
  button.newButton(5,10,15,3,toShell)
  button.newButton(5,15,15,3,boot)
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

-- Roll custom dofile to include environment
local function dolib(lib,env)
  env = env or _ENV
  local func = loadfile(lib,"t",env)
  return func()
end

if not fs.exists(path("libraries/log.lua")) then
  error("libraries/log.lua is missing! SkyOS can not continue boot!")
end
local logging = require("libraries.log")
-- normal loading
term.clear()
term.setCursorPos(1,1)
local f = fs.open("SkyOS/settings.cfg","r")
local settings = textutils.unserialize(f.readAll())
f.close()
_G.SkyOS = {}
_G.SkyOS.settings = settings
_G.SkyOS.emu = {}
_G.SkyOS.wins = dofile("libraries/windowmanager.lua")
_G.SkyOS.version = "21.06.0"
_G.SkyOS.data = {
  heldKeys = {},
  event = {},
  winids = {}, -- This is where SkyOS can store information about itself, such as what window id it's desktop is.
}
_G.SkyOS.coro = dolib("libraries/coro.lua")
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

-- Setup logging
local LOG = logging.getLogger("SkyOS")
-- Disable logging :)
LOG.enable(false)
LOG.basicConfig("log.txt","[{asctime}][{level}] {message}","%Y/%m/%d-%H:%M:%S",logging.INFO)

LOG.info("SkyOS")
LOG.info("Contact:")
LOG.info("Github: SkyTheCodeMaster, Discord: SkyCrafter0#6386")
LOG.info("Discord: https://discord.gg/cY7r2Mt7tc")
LOG.info("Checking for emulation...")

SkyOS.emu.levelos = lOS and lUtils and true or false
SkyOS.emu.craftospc = periphemu and config and true or false
SkyOS.emu.ccemux = ccemux and true or false
SkyOS.emu.phileos = PhileOS and true or false

LOG.info("LevelOS: " .. tostring(SkyOS.emu.levelos))
LOG.info("CraftOS-PC: " .. tostring(SkyOS.emu.craftospc))
LOG.info("CCEmuX: " .. tostring(SkyOS.emu.ccemux))
LOG.info("PhileOS: " .. tostring(SkyOS.emu.phileos))

if SkyOS.emu.levelos then
  LOG.info("Running LevelOS-specific functions")
  local x,y = LevelOS.self.window.win.getPosition()
  LevelOS.self.window.win.reposition(x,y,26,20)
  LevelOS.self.window.resizable = false
  LevelOS.self.window.title = "SkyOS " .. SkyOS.version
end
if SkyOS.emu.phileos then
  LOG.info("Running PhileOS-specific functions")
  local id = PhileOS.ID
  PhileOS.setSize(id,26,20)
  PhileOS.setName(id,"SkyOS " .. SkyOS.version)
  PhileOS.setCanResize(id,false)
end

-- Quickload boot splash by utilizing the mini skimg library.
require("libraries.skimg")("graphics/bootSplash.skimg")()

local sUtils =  dolib("libraries/sUtils.lua")
local sos =     dolib("libraries/sos.lua")
local button =  dolib("libraries/button.lua")
local gesture = dolib("libraries/gesturemanager.lua")


--[[if fs.exists(path("beta.skprg")) then
    SkyOS.sLog.info("Beta version of SkyOS, pausing 1 second to emulate server comms")
    sleep(1)
end]]
local topwin,bottomwin
-- Setup GPS override
local oldlocate = gps.locate
function _G.gps.locate(...)
  if SkyOS.settings.location then
    topwin.setCursorPos(25,1)
    topwin.blit("\023","0","7")
    local x,y,z = oldlocate(...)
    topwin.setCursorPos(25,1)
    topwin.blit("\023","8","7")
    return x,y,z
  else
    topwin.setCursorPos(25,1)
    topwin.blit("\023","e","7") -- Just re affirm that GPS is off :)
    return nil,nil,nil
  end
end

--Do server side things BEFORE term.clear()

term.setBackgroundColour(colours.black)
--Begin auto version check

term.clear()

--Load DE

local function drawTime(x,y,backColour,textColour,tOutput)
  local time
  if SkyOS.settings.useRealtime then
    local timetable = sUtils.getTime(SkyOS.settings.timezone)
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
  tOutput.setCursorPos(x,y)
  tOutput.setBackgroundColour(backColour)
  tOutput.setTextColour(textColour)
  tOutput.write(time)
end

topwin = window.create(term.current(),1,1,26,1,true) -- Window for the top bar.
bottomwin = window.create(term.current(),1,20,26,true) -- Window for the bottom bar.
do -- Keep all the initial drawing in it's own `do end` block, shall we?
  local topbar = sUtils.asset.load(path("graphics/topbar.skimg"))
  local tskbar = sUtils.asset.load(path("graphics/taskbar.skimg"))
  sUtils.asset.drawSkimg(topbar,1,1,topwin)
  sUtils.asset.drawSkimg(tskbar,1,1,bottomwin)
  topwin.setCursorPos(25,1)
  topwin.blit("\023",SkyOS.settings.location and "8" or "e","7")
end
local barButtons = {top={},bot={}} -- barButtons.top(bar), barButtoms.bot(tombar)

local function main() -- This thread will handle parts of SkyOS such as the top and bottom button bars.
  while true do
    -- Draw the time
    drawTime(1,1,colours.grey,colours.white,topwin) -- The time should still go at the top left regardless of whether or not the notification center is open or not, but it being grey might be a different story,
    -- I'm considering having it turn black when the notification center is open, which is easy as it's a simple ternary (`centerOpen and colours.black or colours.grey`)
    -- Handle screenshots
    if SkyOS.wins.topbar then -- If the top bar is visible, then visible & enable it's buttons.
      topwin.setVisible(true)
      for _,v in pairs(barButtons.top) do
        button.enableButton(v,true)
      end
    else -- Disable it all!
      topwin.setVisible(false)
      for _,v in pairs(barButtons.top) do
        button.enableButton(v,false)
      end
    end
    -- Now do it again for the bottom bar!
    if SkyOS.wins.bottombar then
      bottomwin.setVisible(true)
      for _,v in pairs(barButtons.bot) do
        button.enableButton(v,true)
      end
    else
      bottomwin.setVisible(false)
      for _,v in pairs(barButtons.bot) do
        button.enableButton(v,false)
      end
    end
    os.queueEvent("mainYield")
    coroutine.yield()
  end
end

barButtons.bot.homeButton = button.newButton(12,20,3,1,function() SkyOS.wins.foreground(SkyOS.data.winids.desktop) end)
barButtons.bot.back = button.newButton(6,20,3,1,function() SkyOS.wins.wins[SkyOS.wins.activeWindow].env.SkyOS.back() end)
barButtons.bot.taskView = button.newButton(19,20,21,1,function() end) -- Currently does nothing, because I don't know exactly what I want to do here yet.
-- Top button(s) not implemented yet. Deal w/ it.

local function eventMan() -- Utility manager, mostly provides `SkyOS.data.event` and `SkyOS.data.heldKeys`
  while true do
    SkyOS.data.event = {coroutine.yield()}
    local event = SkyOS.data.event
    if event[1] == "mouse_click" then
      button.executeButtons(event,false)
    elseif event[1] == "key" then
      SkyOS.data.heldKeys[event[2]] = true
    elseif event[1] == "key_up" then
      SkyOS.data.heldKeys[event[2]] = false
    end
  end
end

local skyospid = SkyOS.coro.newCoro(main,"SkyOS") -- This is the main loop for skyos, it is important.
local eventpid = SkyOS.coro.newCoro(eventMan,"Event Manager",nil,nil,true) -- This manages events for SkyOS, it is important.
local gpid = SkyOS.coro.newCoro(gesture.run,"Gestures",nil,nil,true)

-- Start the desktop


LOG.info("Process IDs for main SkyOS processes.")
LOG.info(tostring(skyospid))
LOG.info(tostring(eventpid))
LOG.info(tostring(gpid)) -- Thanks Illuaminate! These are now used variables.

local desktopwid = SkyOS.wins.newWindow("programs/desktop.lua","Desktop")

SkyOS.coro.runCoros()
 
-- Colours
--local promptColour  = colours.yellow
--local textColour = colours.white
--local bgColour = colours.blue
--
--term.setBackgroundColor(bgColour)
--term.clear()
--term.setTextColour(promptColour)
--print("SkyShell v21.04")
--term.setTextColour(textColour)
--
---- Read commands and execute them
--local tCommandHistory = {}
--while true do
--  term.setBackgroundColor(bgColour)
--  term.setTextColour(promptColour)
--  write(shell.dir() .. ":S> ")
--  term.setTextColour(textColour)
--  local sLine
--  if settings.get("shell.autocomplete") then
--    sLine = read(nil, tCommandHistory, shell.complete)
--  else
--    sLine = read(nil, tCommandHistory)
--  end
--  if sLine == "update" then
--    sos.updateSkyOS()
--  else
--    if sLine:match("%S") and tCommandHistory[#tCommandHistory] ~= sLine then
--      table.insert(tCommandHistory, sLine)
--    end
--    shell.run(sLine)
--  end
--end
