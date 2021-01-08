
local progressBar = {}

if not fs.exists("libraries/graphic.lua") then
  local h,err = http.get("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyOS/master/libraries/graphic.lua")
  if not h then error(err) end
  local f = fs.open("libraries/graphic.lua","w")
  f.write(h.readAll())
  f.close()
  h.close()
end

local graphic = require("libraries.graphic")
local to_colors, to_blit = {}, {}
for i = 1, 16 do
    to_blit[2^(i-1)] = ("0123456789abcdef"):sub(i, i)
    to_colors[("0123456789abcdef"):sub(i, i)] = 2^(i-1)
end
local bars = {}

-- fill or filled is a PERCENTAGE of how full the bar is.

function progressBar.calcFill(len,fill)

  if fill > 100 then fill = 100 end
  local div = 100 / len
  local power = 10
  local result = (math.floor(fill/div * power))/power
  
  return result
end

function progressBar.updateStep(name,step,total)
  local percent = (step/total) * 100
  progressBar.update(name,percent)
end

function progressBar.update(name,filled)
  if not bars[name] then error("bar does not exist") end
  local tableBar = bars[name]

  local _,len,x,y,fg,bg,tOutput,height = tableBar[1],tableBar[2],tableBar[3],tableBar[4],tableBar[5],tableBar[6],tableBar[7],tableBar[8]
  local float = progressBar.calcFill(len,filled)
  local pixels, decimal = math.modf(float)
  if decimal < .5 then
    graphic.drawFilledBox(x,y,len,height,bg,tOutput) -- draw over the old progess bar - useful if progress goes backwards
    graphic.drawFilledBox(x,y,pixels,height,fg,tOutput)
  elseif decimal >= .5  then
    graphic.drawFilledBox(x,y,len,height,bg,tOutput)
    graphic.drawFilledBox(x,y,pixels,height,fg,tOutput)
    for i=tonumber(y),tonumber(height) do
    tOutput.setCursorPos(x+pixels,i)
    tOutput.blit(string.char(149),to_blit[fg],to_blit[bg])
  end
  bars[name] = {filled, len, x, y, fg, bg, tOutput, height}
 end
end

function progressBar.new(x,y,len,height,fg,bg,name,filled,tOutput)
  tOutput = tOutput or term.current()
  filled = filled or 0
  height = height or 0
  height = y + height -- This fixes the god forsaken issue

  graphic.drawFilledBox(x,y,len,height,bg,tOutput) -- draw the background of it

  bars[name] = {filled, len, x, y, fg, bg, tOutput, height}

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
