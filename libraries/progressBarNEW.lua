local progressBar = {}

local expect = require("expect").expect

if not fs.exists("libraries/graphic.lua") then -- Check for existence of libraries/graphic.lua, if not, download it
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
  expect(1,len,"number")
  expect(2,fill,"number")

  if fill > 100 then fill = 100 end
  local div = 100 / len
  local result = math.floor((fill / div) + 0.5)
  
  return result
end

function progressBar.updateStep(name,step,total)
  expect(1,name,"string")
  expect(2,step,"number")
  expect(3,total,"number")
  
  local percent = (step/total) * 100
  progressBar.update(name,percent)
end

function progressBar.update(name,filled)
  expect(1,name,"string")
  expect(2,filled,"number")
  
  if not bars[name] then error("bar does not exist") end

  local bar = bars[name]
  local pixels = progressBar.calcFill(bar.len,filled)

  graphic.drawFilledBox(bar.x,bar.y,bar.len,bar.height,bar.bg,bar.tOutput) -- draw over the old progess bar - useful if progress goes backwards
  graphic.drawFilledBox(bar.x,bar.y,pixels,bar.height,bar.fg,bar.tOutput)
  bars[name] = { x = x, y = y, len = len, height = height, fg = fg, bg = bg, filled = filled, tOutput = tOutput}
  
  return bars[name]
end

function progressBar.new(x,y,len,height,fg,bg,name,filled,tOutput)
  expect(1,x,"number")
  expect(2,y,"number")
  expect(3,len,"number")
  expect(4,height,"number")
  expect(5,fg,"number")
  expect(6,bg,"number")
  expect(7,name,"string")
  expect(8,filled,"number","nil")
  expect(9,tOutput,"table","nil")
  
  tOutput = tOutput or term.current()
  filled = filled or 0
  height = height or 0
  height = y + height -- This fixes the god forsaken issue

  graphic.drawFilledBox(x,y,len,height,bg,tOutput) -- draw the background of it

  bars[name] = { x = x, y = y, len = len, height = height, fg = fg, bg = bg, filled = filled, tOutput = tOutput}

  if filled ~= 0 then
    progressBar.update(name,filled,tOutput) -- if `filled` variable is passed, fill the progress bar to that amount.
  end

  return name, bars[name]
end

function pg.edit(name,index)
  expect(1,name,"string")
  expect(2,index,"table")
  
  if bars[name] == nil then error("bar does not exist") end
  local new = {}
  local old = bars[name]
  if not index.x then new.x = old.x end
  if not index.y then new.y = old.y end
  if not index.len then new.len = old.len end
  if not index.height then new.height = old.height end
  if not index.fg then new.fg = old.fg end
  if not index.bg then new.bg = old.bg end
  if not index.filled then new.filled = old.filled end
  if not index.tOutput then new.tOutput = old.tOutput end
  
  bars[name] = new
  
  return bars[name]
end

return progressBar
