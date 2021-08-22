-- First program of SkyOS, the desktop.
-- It will adhere to the `SkyOS Desktop` article on SkyDocs, with some extra features
--[[
  Such features include:
  Swiping left & right to change windows
  Clicking on an icon will open it's respective program, and hide the desktop.
  It uh, it'll auto update it's background?

]]

local sos = require("libraries.sos")
local sUtils = require("libraries.sUtils")
local desktop = sUtils.encfread("SkyOS/desktop.cfg")
local button = require("libraries.button")
_G.SkyOS.data.winids.desktop = _ENV.SkyOS.self.winid -- Place the desktop into the global SkyOS, and to have the task switcher *not* show the desktop.

local desktopBackground = sUtils.asset.load(SkyOS.settings.desktopImg)
SkyOS.wins.bottombarOpen = true
SkyOS.wins.topbarOpen = true
local selectedScreen = 1 -- Which screen is currently selected?

local imageCache = {{},{},{},{},}

--- Draw a screen with the apps in front, this function allows for rendering type 2 skimgs.
-- @tparam number screen Screen of apps to draw. This should correspond with the buttons available.
local function drawApps(screen)
  for y,v in ipairs(desktop[selectedScreen]) do
    for x,b in ipairs(v) do
      if b.type == "app" then
        local image = sUtils.asset.load(b.image)
        -- Calculate x/y coordinates
        sUtils.asset.draw(image,{x=2*(3*x-2),y=3*(2*y-1)})
      end
    end
  end
end

-- Initialize buttons
local buttons = {{},{},{},{}}
for y=1,4 do
  for x=1,4 do
    buttons[y][x] = button.newButton(2*(3*x-2),3*(2*y-1),5,5,function() end)
  end
end

local function setScreen(screen)
  drawApps(screen)
  -- Load buttons
  for y,v in ipairs(desktop[selectedScreen]) do
    for x,b in ipairs(v) do
      if b.type == "app" then
        button.editButton(buttons[y][x],nil,nil,nil,nil,function() SkyOS.wins.newWindow(b.program, b.name, true) end)
      end
    end
  end

end
