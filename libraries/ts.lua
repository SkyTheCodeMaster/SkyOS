local modem = peripheral.find("modem")
local tsSend = 27793
 
local pcReturn = math.random(30000,40000)
modem.open(pcReturn)

local ts = {}
 
function ts.get(offset)
  modem.transmit(tsSend,pcReturn,offset)
  local _,_,_,_,msg = os.pullEvent("modem_message")
  return msg
end
 
return ts
