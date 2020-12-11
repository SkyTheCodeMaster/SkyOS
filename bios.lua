_G.paintutils = require("libraries.apis.paintutils")
_G.file = require("libraries.file")
_G.graphic = require("libraries.file")
local graphic = require("libraries.graphic")
local file = require("libraries.file")
local x,y = term.getSize()
local dbFile = "data/main.skydb"
 
term.setBackgroundColour(colours.blue)
term.setTextColour(colours.white)
term.clear()
-- load variables into global environment
local dbHandle = fs.open(dbFile,"r")
_G.SkyOS = {}
local tData = textutils.unserialise(dbHandle.readAll())
_G.SkyOS = tData
dbHandle.close()
 
graphic.drawBox(1,0,x,y-1,colours.white)
-- draw storefront image
os.loadAPI("images/image.lua")
local shopFront = peripheral.wrap(SkyOS.monitors.storeFront)
shopFront.setTextScale(0.5)
image.draw(shopFront)
os.unloadAPI("image")
-- begin loading bg processes
shell.run("bg bg/timeserver.lua")
