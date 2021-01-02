local turtleChannel = 23654
local tM = peripheral.wrap(SkyOS.monitors.turtle)
local modem = peripheral.wrap(SkyOS.modems.turtle)
local baseImage = "images/turtle/base.skgrp"
 
modem.open(turtleChannel)
-- Keep consistent blue theme on computer
term.setBackgroundColour(colours.blue)
term.setTextColour(colours.white)
term.clear()
-- Initialize the monitor
tM.setBackgroundColour(colours.blue)
tM.setTextColour(colours.white)
tM.clear()
tM.setTextScale(2)
tM.setCursorPos(1,1)
 
local posTable = {
  standard = {
    name = 1,
    status = 10,
    fuel = 17,
  },
  hemp = {
    y = 3,
    time = 900,
  },
  sugar = {
    y = 4,
    time = 1800,
  },
  inferium = {
    y = 5,
    time = 3000,
  },
  supremium = {
    y = 6,
    time = 30,
  },
}
 
-- Draw base image
file.loadGrpLines(baseImage,tM)
 
local function drawCount(x,y,i,limit)
  tM.setCursorPos(x,y)
  tM.write("      ")
  tM.setCursorPos(x,y)
  tM.write(tostring(limit-i).."s")
end
 
local function hemp()
  local y = posTable.hemp.y
  local time = posTable.hemp.time
  local hempTable = {
    namePos = {posTable.standard.name,y},
    statusPos = {posTable.standard.status,y},
    fuelPos = {posTable.standard.fuel,y}
  }
  tM.setCursorPos(unpack(hempTable.namePos))
  tM.write("WeedFarm")
  while true do
    tM.setCursorPos(unpack(hempTable.statusPos))
    tM.write("ACTIVE")
    modem.transmit(turtleChannel,turtleChannel,{"hemp","farm"})
    local msg
    repeat _,_,sC,_,msg = os.pullEvent("modem_message")
    until sC == turtleChannel and msg[1] == "hempDone"
    local fuel = msg[2]
    tM.setCursorPos(unpack(hempTable.fuelPos))
    tM.write(tostring(fuel))
    for i=1,time do
      drawCount(hempTable.statusPos[1],hempTable.statusPos[2],i,time)
      sleep(1)
    end
  end
end
 
local function sugarcane()
  local y = posTable.sugar.y
  local time = posTable.sugar.time
  local sugarTable = {
    namePos = {posTable.standard.name,y},
    statusPos = {posTable.standard.status,y},
    fuelPos = {posTable.standard.fuel,y}
  }
  tM.setCursorPos(unpack(sugarTable.namePos))
  tM.write("S. Cane")
  while true do
    modem.transmit(turtleChannel,turtleChannel,{"cane","farm"})
    tM.setCursorPos(unpack(sugarTable.statusPos))
    tM.write("ACTIVE")
    local msg
    repeat _,_,sC,_,msg = os.pullEvent("modem_message")
    until sC == turtleChannel and msg[1] == "caneDone"
    local fuel = msg[2]
    tM.setCursorPos(unpack(sugarTable.fuelPos))
    tM.write(tostring(fuel))
    for i=1,time do
      drawCount(sugarTable.statusPos[1],sugarTable.statusPos[2],i,time)
      sleep(1)
    end
  end
end
 
local function inferium()
  local y = posTable.inferium.y
  local time = posTable.inferium.time
  local inferiumTable = {
    namePos = {posTable.standard.name,y},
    statusPos = {posTable.standard.status,y},
    fuelPos = {posTable.standard.fuel,y}
  }
  tM.setCursorPos(unpack(inferiumTable.namePos))
  tM.write("Inferium")
  while true do
    modem.transmit(turtleChannel,turtleChannel,{"inferium","farm"})
    tM.setCursorPos(unpack(inferiumTable.statusPos))
    tM.write("ACTIVE")
    local msg
    repeat _,_,sC,_,msg = os.pullEvent("modem_message")
    until sC == turtleChannel and msg[1] == "inferiumDone"
    local fuel = msg[2]
    tM.setCursorPos(unpack(inferiumTable.fuelPos))
    tM.write(tostring(fuel))
    for i=1,time do
      drawCount(inferiumTable.statusPos[1],inferiumTable.statusPos[2],i,time)
      sleep(1)
    end
  end
end

local function supremium()
  local y = posTable.supremium.y
  local time = posTable.supremium.time
  local supremiumTable = {
    namePos = {posTable.standard.name,y},
    statusPos = {posTable.standard.status,y},
    fuelPos = {posTable.standard.fuel,y}
  }
  tM.setCursorPos(unpack(supremiumTable.namePos))
  tM.write("Craft-U1")
  while true do
    modem.transmit(turtleChannel,turtleChannel,{"supremium","farm"})
    tM.setCursorPos(unpack(supremiumTable.statusPos))
    tM.write("ACTIVE")
    local msg
    repeat _,_,sC,_,msg = os.pullEvent("modem_message")
    until sC == turtleChannel and msg[1] == "inferiumDone"
    local fuel = msg[2]
    tM.setCursorPos(unpack(supremiumTable.fuelPos))
    tM.write(tostring(fuel))
    for i=1,time do
      drawCount(supremiumTable.statusPos[1],supremiumTable.statusPos[2],i,time)
      sleep(1)
    end
  end
end
parallel.waitForAny(hemp,sugarcane,inferium,supremium)
