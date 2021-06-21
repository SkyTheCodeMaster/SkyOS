-- Re implement the following features:
--[[
  os = {"version", "pullEventRaw", "pullEvent", "loadAPI", "unloadAPI", "sleep"}
  load api is garbage. SkyOS will simply have to make do without it. boo hoo :(
  version will return `SkyOS 21.06.x` or whatnot
]]

_G.os.version = function()
  return "SkyOS 21.06.3"
end

_G.os.pullEventRaw = function(...)
  return coroutine.yield(...)
end

_G.os.pullEvent = function(...)
  local e = table.pack(coroutine.yield(...))
  if e[1] == "terminate" then
    error("Program terminated.",0)
  end
  return table.unpack(e,1,e.n)
end

_G.os.sleep = function(time)
  local id = os.startTimer(time or 0)
  repeat
    local _,tid = os.pullEvent("timer")
  until tid == id
end