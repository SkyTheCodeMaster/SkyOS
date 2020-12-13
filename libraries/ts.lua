local modem = peripheral.find("modem")
local tsSend = 27793
 
local pcReturn = math.random(30000,40000)
modem.open(pcReturn)

local ts = {}
 
function ts.get(offset)
  if not SkyOS.settings.timeServerEnabled then
    local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * timezone) 
    local t = os.date("!*t", epoch)
    return t,tostring(t.hour) .. ":" .. tostring(t.min) .. ":" .. tostring(t.sec),tostring(t.hour) .. ":" .. tostring(t.min)
  end
  modem.transmit(tsSend,pcReturn,offset)
  local _,_,_,_,msg = os.pullEvent("modem_message")
  return msg
end
 
return ts
