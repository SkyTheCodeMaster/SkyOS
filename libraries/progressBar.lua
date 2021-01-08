
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

local bars = {}

-- fill or filled is a PERCENTAGE of how full the bar is.

function progressBar.calcFill(len,fill)

  if fill > 100 then fill = 100 end
  local div = 100 / len
  local result = math.floor((fill / div) + 0.5)
  
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
  local pixels = progressBar.calcFill(len,filled)

  graphic.drawFilledBox(x,y,len,height,bg,tOutput) -- draw over the old progess bar - useful if progress goes backwards
  graphic.drawFilledBox(x,y,pixels,height,fg,tOutput)
  bars[name] = {filled, len, x, y, fg, bg, tOutput, height}
end

function progressBar.new(x,y,len,height,fg,bg,name,filled,tOutput)
  tOutput = tOutput or term.current()
  filled = filled or 0
  height = height or 0 -- change to 0 since of the height = y + height meaning that if it defaults to 1 it would be a 2 thick bar instead of just 1
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
