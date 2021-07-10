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
_G.SkyOS.data.winids.desktop = _ENV.SkyOS.self.winid -- Place the desktop into the global SkyOS, and to have the task switcher *not* show the desktop.

local desktopBackground = sUtils.asset.load(SkyOS.settings.desktopImg)
SkyOS.wins.bottombarOpen = true
SkyOS.wins.topbarOpen = true

