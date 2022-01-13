-- First program of SkyOS, the desktop.
-- It will adhere to the `SkyOS Desktop` article on SkyDocs, with some extra features
--[[
  Such features include:
  Swiping left & right to change windows
  Clicking on an icon will open it's respective program, and hide the desktop.
  It uh, it'll auto update it's background?

]]

-- Roll custom dofile to include environment
local function dolib(lib,env)
  env = env or _ENV
  local func = assert(loadfile(lib,"t",env))
  return func()
end

local sos =     dolib("libraries/sos.lua")
local sUtils =  dolib("libraries/sUtils.lua")
local button =  dolib("libraries/button.lua")
local coro =    dolib("libraries/coro.lua")
local desktop = sUtils.encfread("SkyOS/desktop.cfg")

_G.SkyOS.data.winids.desktop = _ENV.SkyOS.self.winid -- Place the desktop into the global SkyOS, and to have the task switcher *not* show the desktop.

local desktopBackground = sUtils.asset.load(SkyOS.settings.desktopImg)
SkyOS.wins.bottombar = true
SkyOS.wins.topbar = true
local selectedScreen = 1 -- Which screen is currently selected?

local imageCache = {{},{},{},{}}

--- Draw a screen with the apps in front, this function allows for rendering type 2 skimgs.
-- @tparam number screen Screen of apps to draw. This should correspond with the buttons available.
local function drawApps(image,screen)
  if image then
    local data = image.data or image -- Pull skimg data, or just the image itself (skimg or blit format)
    for i,v in ipairs(data) do
      term.setCursorPos(1,i)
      term.blit(v[1],v[2],v[3])
    end
  end
  for y,v in ipairs(desktop[screen]) do
    for x,b in ipairs(v) do
      if b.type == "app" then
        -- Calculate x/y coordinates
        local _,_,line = term.getLine(5*y)
        sUtils.asset.draw(imageCache[y][x],{x=5*x-2,y=5*y-3},term)
        term.setCursorPos(5*x-2,5*y)
        local section = line:sub(5*x-2,5*x+1)
        term.blit(b.name,"0000",section)
      end
    end
  end
end

-- Initialize buttons
local buttons = {{},{},{},{}}
for y=1,4 do
  for x=1,4 do
    buttons[y][x] = button.newButton(5*x-2,5*y-3,5,5,function() end)
  end
end

-- This function should only be called once per screenset
local function setScreen(screen)
  selectedScreen = screen
  -- Load buttons
  for y,v in ipairs(desktop[screen]) do
    for x,b in ipairs(v) do
      if b.type == "app" then
        button.editButton(buttons[y][x],nil,nil,nil,nil,function() SkyOS.wins.foreground(SkyOS.wins.newWindow(b.program, b.name, true)) end)
        imageCache[y][x] = sUtils.asset.load(b.image)
      end
    end
  end
end
--- Custom type 2 skimg loader to support animated playback.
local function draw2skimg(skimg)
  -- Basically calls the type 1 parser on each frame, with a `sleep` in between.
  -- make sure terminal has blit and setCursorPos
  if not term.setCursorPos or not term.blit then
    error("Terminal is incompatible!",2)
  end
  local frames = skimg.data
  for _,v in ipairs(frames) do
    local frame = v
    term.setVisible(false)
    for i,l in ipairs(frame) do
      term.setCursorPos(1,i)
      term.blit(l[1],l[2],l[3])
    end
    drawApps(nil,selectedScreen)
    term.setVisible(true)
    sleep(skimg.attributes.speed or 0.05)
  end
end

-- Functions
local function handleButtons()
  while true do
    local event = {os.pullEvent()}
    button.executeButtons(event,false,false)
  end
end

local function drawScreen()
  while true do
    if desktopBackground["format"] == "skimg" and desktopBackground["attributes"]["type"] == 2 then
      draw2skimg(desktopBackground)
    else
      term.setVisible(false)
      drawApps(desktopBackground,selectedScreen)
      term.setVisible(true)
      sleep()
    end
  end
end

setScreen(1)
SkyOS.wins.foreground(SkyOS.self.winid)

-- Now create the coroutines
local buttonCoro = coro.newCoro(handleButtons,"button")
local screenCoro = coro.newCoro(drawScreen,"screen")

-- Finally, start the program.
coro.runCoros()
