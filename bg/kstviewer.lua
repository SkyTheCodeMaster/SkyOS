local function cut(str,len,pad)
  pad = pad or " "
  return str:sub(1,len) .. pad:rep(len - #str)
end

local function calcHashrate(work)
  local rate = 1 / (tonumber(work) / (256 ^ 6)) * 60
  if rate == 0 then return ("0 H/s") end
  
  local sizes = {"H","KH","MH","GH","TH"}
  local i = math.floor(math.log(rate) / math.log(1000))
  return tostring(string.format("%0.2f", (rate / 1000 ^ i))) .. " " .. sizes[i] .. "/s"
end
 
local response,err = http.post("https://krist.ceriat.net/ws/start","{}")
if not response then error(err) end
 
local responseJSON = textutils.unserializeJSON(response.readAll())
local socket,err = http.websocket(responseJSON.url)
if not socket then error(err) end
 
socket.receive()
local msgID = math.random(1,1000)
 
local mon = peripheral.wrap(SkyOS.monitors.krist)
 
file.loadGrpLines("images/krist.skgrp",mon)
 
term.setBackgroundColour(colours.blue)
term.clear()

local function main()
  while true do
    msgID = msgID + 1
    socket.send(textutils.serializeJSON({type = "address", id = msgID, address = SkyOS.extra.krist.address}))
    local r = socket.receive()
    local data = textutils.unserializeJSON(r)
    --print(textutils.serialize(data))
    if data.address then
      mon.setTextColour(colours.grey)
      mon.setCursorPos(14,5)
      mon.setBackgroundColour(colours.lightBlue)
      mon.write(tostring(data.address.totalin))
      mon.setBackgroundColour(colours.blue)
      mon.setCursorPos(14,3)
      mon.write(tostring(data.address.address))
      mon.setBackgroundColour(colours.blue)
      mon.setCursorPos(14,6)
      mon.write(tostring(data.address.totalout))
      mon.setTextColour(colours.white)
      bf.writeOn(mon,2,string.char(164) .. tostring(data.address.balance),8,10)
      sleep()
    end
    msgID = msgID + 1
    socket.send(textutils.serializeJSON({type="work",id=msgID}))
    local r = socket.receive()
    local data = textutils.unserializeJSON(r)
    if data.work then
      mon.setBackgroundColour(colours.lightBlue)
      mon.setTextColour(colours.grey)
      mon.setCursorPos(14,7)
      mon.write(cut(tostring(data.work),10))
      sleep()
    end
  end
end

main()
