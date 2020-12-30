local bars = {}

local pga = {}

function pga.create(barName,stepCount,stepNames,curStep)
  curStep = curStep or 1
  bars[barName] = { curStep, stepCount, stepNames }
  
  if curStep ~= 1 then
    local bar = pg.get(barName)
    local tOutput = bar[7]
    local x,y = tOutput.getCursorPos()
    
    pg.updateStep(barName, unpack(bars[barName]))
    tOutput.setCursorPos(bar[3],bar[4]+1)
    tOutput.write("("..tostring(curStep).."/"..tostring(stepCount)..") "..stepNames[curStep])
    tOutout.setCursorPos(x,y)
  end
  return barName
end

function pga.update(barName,curStep)
  if bars[barName] == nil then error("bar does not exist") end
  curStep = curStep or 1
  local bar = pg.get(barName)
  local tOutput = bar[7]
  local x,y = tOutput.getCursorPos()
  local pgaBar = bars[barName]
  local stepCount,stepNames = pgaBar[2],pgaBar[3]
  
  pg.updateStep(barName, unpack(bars[barName]))
  tOutput.setCursorPos(bar[3],bar[4]+1)
  tOutput.write("("..tostring(curStep).."/"..tostring(stepCount)..") "..stepNames[curStep])
  tOutput.setCursorPos(x,y)
  pgaBar = { curStep, stepCount, stepNames }
  bars[barName] = pgaBar
end

function pga.delete(barName)
  bars[barName] = nil
end

return pga
