term.clear()
term.setCursorPos(1,1)
file = require("libraries.file")
file.loadGrpLines("graphics/bootSplash.skgrp")

--Do server side things BEFORE term.clear()
term.setBackgroundColour(colours.black)
term.clear()
--Load DE
file.loadGrpLines("graphics/background/default.skgrp")
file.loadGrpLines("graphics/taskbar.skgrp")
parallel.waitForAll(function() shell.run("customPrograms/timeManager.lua") end, function() shell.run("customPrograms/applications.lua") end)
