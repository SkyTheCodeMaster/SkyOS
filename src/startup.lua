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

if not fs.exists(path("libraries/log.lua")) then
  error("libraries/log.lua is missing! SkyOS can not continue boot!")
end
local log = require("libraries.log")
-- normal loading
term.clear()
term.setCursorPos(1,1)
local f = fs.open("settings/general.cfg")
local settings = textutils.unserialize(f.readAll())
f.close()
_G.SkyOS = {}
_G.SkyOS.settings = settings
_G.SkyOS.emu = {}
_G.SkyOS.wins = {}
_G.SkyOS.version = "21.06.0"
_G.SkyOS.data = {
  heldKeys = {},
  event = {},
  winids = {}, -- This is where SkyOS can store information about itself, such as what window id it's desktop is.
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

SkyOS.emu.levelos = lOS and lUtils and true or false
SkyOS.emu.craftospc = periphemu and config and true or false
SkyOS.emu.ccemux = ccemux and true or false
SkyOS.emu.phileos = PhileOS and true or false

mainLog:info("LevelOS: " .. tostring(SkyOS.emu.levelos))
mainLog:info("CraftOS-PC: " .. tostring(SkyOS.emu.craftospc))
mainLog:info("CCEmuX: " .. tostring(SkyOS.emu.ccemux))
mainLog:info("PhileOS: " .. tostring(SkyOS.emu.phileos))

if SkyOS.emu.levelos then
  mainLog:info("Running LevelOS-specific functions")
  local x,y = LevelOS.self.window.win.getPosition()
  LevelOS.self.window.win.reposition(x,y,26,20)
  LevelOS.self.window.resizable = false
  LevelOS.self.window.title = "SkyOS " .. SkyOS.version
end
if SkyOS.emu.phileos then
  mainLog:info("Running PhileOS-specific functions")
  local id = PhileOS.ID
  PhileOS.setSize(id,26,20)
  PhileOS.setName(id,"SkyOS " .. SkyOS.version)
  PhileOS.setCanResize(id,false)
end

-- Quickload boot splash by utilizing the mini skimg library.
local skimg = require("libraries.skimg")
local bootSplash = skimg("graphics/bootSplash.skimg")
bootSplash()

local function hread(url)
  local h,err = http.get(url)
  if not h then return nil,err end
  local contents = h.readAll()
  h.close()
  return contents
end
local function split(inputstr,sep)
  sep = sep or ","
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
-- Begin integrity check 
if SkyOS.settings.internet and SkyOS.settings.verifyIntegrity then
  local function getFiles(recursive,url,filter,path)
    local contents
    if filter then
      local splitURL = split(url,"/")
      local apiURL = ("https://api.github.com/repos/%s/%s/contents/%s?ref=%s"):format(splitURL[3], splitURL[4], table.concat(splitURL, "/", 7), splitURL[6]) -- Thanks, JackMacWindows!
      contents = textutils.unserializeJSON(hread(apiURL))
    else
      contents = textutils.unserializeJSON(hread(url))
    end
    local files = {}
    for _,v in pairs(contents) do
      if v.type == "dir" and recursive then
        local newFiles = getFiles(true,v["_links"].self,false,fs.combine(path,v.name))
        for url,path in pairs(newFiles) do files[url] = path end
      end
      if v.type == "file" then
        local name = fs.getName(v.path)
        local path = fs.combine(path,name)
        files[v.download_url] = path
      end
    end
    return files
  end
  -- Necessary libraries for integrity check, we best damned hope they exist and work
  if not fs.exists(path("libraries/progressBar.lua")) or not fs.exists(path("libraries/crash.lua")) then
    SkyOS.displayError("Integrity check is missing necessary files!\nlibraries/progressBar.lua\nlibraries/crash.lua")
  end
  local progressBar = require("libraries.progressBar")
  local crash = require("libraries.crash")
  local integrity = skimg("graphics/integrity.skimg")
  local integrityBar = progressBar(1,16,26,1,colours.lime,colours.grey)
  integrity(1,15)
  local filesJSON,err = hread("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyOS/master/requirements.json")
  if not filesJSON then crash("nil",err,"Failed to get requirements.json for integrity check") SkyOS.displayError(err) end
  local files = textutils.unserializeJSON(filesJSON)
  -- Get a count of all the files in the table, and trim the graphics folder.
  local count = 0
  for k,v in pairs(files) do
    if v.folder then
      files[k] = nil
      local folder = getFiles(v.recursive,k,true,v.path)
      for k,v in pairs(folder) do files[k] = v end
    end
  end
  for _ in pairs(files) do count = count + 1 end
  local processed = 0
  -- Now begin the actual check
  for k,v in pairs(files) do
    if not fs.exists(path(v.path)) then
      local file = hread(k)
      if file then
        local f = fs.open(v.path,"w")
        f.write(file)
        f.close()
      end
    end
    processed = processed + 1
    integrityBar:update(math.floor(processed/count*100))
  end
end

local sUtils = require("libraries.sUtils")
local sos = require("libraries.sos")
local button = require("libraries.button")
local gesture = require("libraries.gesturemanager")

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

-- Setup FS override
-- Protected files/directories. If path:match(x) then it will be access denied on a w/a access.
local protected = {
  "SkyOS/defaults/",
}
local oldOpen = fs.open
local oldRO = fs.isReadOnly
local function readOnly(path)
  for _,v in pairs(protected) do
    if path:match(v) then
      return false
    end
  end
  return oldRO(path)
end

fs.isReadOnly = readOnly

local protectedModes = {
  w = true,
  wb = true,
  a = true,
  ab = true,
}

function fs.open(path,mode)
  if protectedModes[mode] then
    if readOnly(path) then
      return nil,path .. ": Access denied"
    end
  end
  return oldOpen(path,mode)
end

mainLog:save()
--Do server side things BEFORE term.clear()

term.setBackgroundColour(colours.black)
--Begin auto version check

-- tlco
-- TODO: Figure out how to properly do a TLCO to make Rednet toggle-able in settings.
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

local function drawHomescreen()
  local desktopImg = sUtils.asset.load(path(SkyOS.settings.desktopImg))
  sUtils.asset.drawSkimg(desktopImg,1,2)
end

drawHomescreen()

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

local skyospid = SkyOS.coro.newCoro(main,"SkyOS") -- This is the main loop for skyos, it is important.
local eventpid = SkyOS.coro.newCoro(eventMan,"Event Manager",nil,nil,true) -- This manages events for SkyOS, it is important.
local gpid = SkyOS.coro.newCoro(gesture.run,"Gestures",nil,nil,true)
mainLog:info("Process IDs for main SkyOS processes.")
mainLog:info(tostring(skyospid))
mainLog:info(tostring(eventpid))
mainLog:info(tostring(gpid)) -- Thanks Illuaminate! These are now used variables.
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
