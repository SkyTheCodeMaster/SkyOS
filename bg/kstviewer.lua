local response,err = http.post("https://krist.ceriat.net/ws/start","{}")
if not response then error(err) end
 
local responseJSON = textutils.unserializeJSON(response.readAll())
local socket,err = http.websocket(responseJSON.url)
if not socket then error(err) end
 
socket.receive()
local msgID = math.random(1,1000)
 
local mon = peripheral.wrap(SkyOS.monitors.krist)
local bf = require("libraries.bigfontSC")
 
file.loadGrpLines("images/krist.skgrp",mon)
 
term.setBackgroundColour(colours.blue)
term.clear()
 
while true do
  msgID = msgID + 1
  socket.send(textutils.serializeJSON({type = "address", id = msgID, address = SkyOS.extra.krist.address}))
  local r = socket.receive()
  local data = textutils.unserializeJSON(r)
  --print(textutils.serialize(data))
  if data.type ~= "keepalive" then
    mon.setTextColour(colours.grey)
    mon.setCursorPos(14,5)
    mon.setBackgroundColour(colours.lightBlue)
    mon.write(tostring(data.address.totalin))
    mon.setCursorPos(14,7)
    mon.write(tostring(data.address.address))
    mon.setBackgroundColour(colours.blue)
    mon.setCursorPos(14,6)
    mon.write(tostring(data.address.totalout))
    mon.setTextColour(colours.white)
    bf.writeOn(mon,2,string.char(164) .. tostring(data.address.balance),8,10)
    sleep()
  end
end
