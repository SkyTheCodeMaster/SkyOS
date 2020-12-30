local progressBar = {}



local bars = {}

-- fill or filled is a PERCENTAGE of how full the bar is.

function progressBar.calcFill(len,fill)

  if fill > 100 then fill = 100 end
  local div = 100 / len
  local result = math.floor((fill / div) + 0.5)
  
  return result

end

local function calcSteps(step,total)
  return step/total
end

function progressBar.updateStep(name,step,total)
  local percent = calcSteps(step,total) * 100
  progressBar.update(name,percent)
end

function progressBar.update(name,filled)
  if not bars[name] then error("bar does not exist") end
  local tableBar = bars[name]

  local _,len,x,y,fg,bg,tOutput = tableBar[1],tableBar[2],tableBar[3],tableBar[4],tableBar[5],tableBar[6],tableBar[7]
  local pixels = progressBar.calcFill(len,filled)

  SkyOS.lib.graphic.drawFilledBox(x,y,len,y,bg,tOutput) -- draw over the old progess bar - useful if progress goes backwards
  SkyOS.lib.graphic.drawFilledBox(x,y,pixels,y,fg,tOutput)
  bars[name] = {filled, len, x, y, fg, bg, tOutput}
end

function progressBar.new(x,y,len,fg,bg,name,filled,tOutput)
  tOutput = tOutput or term.current()
  filled = filled or 0

  SkyOS.lib.graphic.drawFilledBox(x,y,len,y,bg,tOutput) -- draw the background of it

  bars[name] = {filled, len, x, y, fg, bg, tOutput}

  if filled ~= 0 then
    progressBar.update(name,filled,tOutput) -- if `filled` variable is passed, fill the progress bar to that amount.
  end

  return name
end

function progressBar.getFill(name)
  if not bars[name] then error("bar does not exist") end

  local tableBar = bars[name]
  
  return tableBar[1]
end

function progressBar.get(name)
  if not bars[name] then error("bar does not exist") end
  return bars[name]
end

return progressBar
