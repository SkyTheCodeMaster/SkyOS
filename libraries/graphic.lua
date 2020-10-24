local graphic = {}
 
-- Graphics library for SkyOS
 
local to_colors, to_blit = {}, {}
for i = 1, 16 do
    to_blit[2^(i-1)] = ("0123456789abcdef"):sub(i, i)
    to_colors[("0123456789abcdef"):sub(i, i)] = 2^(i-1)
end

function graphic.drawFilledBox(x1,y1,x2,y2,c) -- (bg and fg provided in blit format)
  sLog.info("[grp] drawing filled box " .. tostring(x1) .. " " .. tostring(y1) .. " " .. tostring(x2) .. " " .. tostring(y2) .. " " .. tostring(c))
  local currentX,currentY = term.getCursorPos()
  local col = to_blit[c]
  local w = (tonumber(x2)-tonumber(x1))+1
  for i=tonumber(y1),tonumber(y2) do
    term.setCursorPos(tonumber(x1),i)
    term.blit(string.rep(" ",w),string.rep(col,w),string.rep(col,w))
  end
  term.setCursorPos(currentX,currentY)
end
 
function graphic.drawBox(arg1, arg2, arg3, arg4, arg5)
 sLog.info("[grp] drawing box " .. tostring(arg1) .. " " .. tostring(arg2) .. " " .. tostring(arg3) .. " " .. tostring(arg4) .. " " .. tostring(arg5))
--arg1 is top left x
--arg2 is top left y
--arg3 bottom right x
--arg4 is bottom right y
--arg5 is color (colors.black)
    currentColour = term.getBackgroundColour()
    currentTextColour = term.getTextColour()
    currentX, currentY = term.getCursorPos()
 
    paintutils.drawBox(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))
 
    
    term.setTextColour(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColour(currentColour)
end
 
function graphic.drawPixel(arg1, arg2, arg3)
 sLog.info("[grp] drawing pixel " .. tostring(arg1) .. " " .. tostring(arg2) .. " " .. tostring(arg3))
--arg1 is x
--arg2 is y
--arg3 is color (colors.black)
    currentColour = term.getBackgroundColor()
    currentTextColour = term.getTextColor()
    currentX, currentY = term.getCursorPos()
    
    paintutils.drawPixel(tonumber(arg1),tonumber(arg2),tonumber(arg3))
    
    term.setTextColour(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColour(currentColour)
    
end
 
function graphic.drawText(arg1,arg2,arg3,arg4,arg5)
 sLog.info("[grp] drawing text " .. tostring(arg1) .. " " .. tostring(arg2) .. " " .. tostring(arg3) .. " " .. tostring(arg4) .. " " .. tostring(arg5))
--arg1 is x
--arg2 is y
--arg3 is text colour
--arg4 is for background colour
--arg5 is string for text. This does not check to see if the text will print offscreen.
    currentTextColour = term.getTextColour()
    currentColour = term.getBackgroundColour()
    currentX, currentY = term.getCursorPos()
    
    term.setCursorPos(tonumber(arg1),tonumber(arg2))
    term.setTextColour(tonumber(arg3))
    term.setBackgroundColour(tonumber(arg4))
    term.write(arg5)
    
    term.setCursorPos(currentX,currentY)
    term.setTextColour(currentTextColour)
    term.setBackgroundColour(currentColour)
end

function graphic.drawLine(arg1, arg2, arg3, arg4, arg5)
 sLog.info("[grp] drawing line " .. tostring(arg1) .. " " .. tostring(arg2) .. " " .. tostring(arg3) .. " " .. tostring(arg4) .. " " .. tostring(arg5))
--arg1 is top left x
--arg2 is top left y
--arg3 bottom right x
--arg4 is bottom right y
--arg5 is color (colors.black)
    currentColour = term.getBackgroundColour()
    currentTextColour = term.getTextColour()
    currentX, currentY = term.getCursorPos()
 
    paintutils.drawLine(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))
 
    
    term.setTextColour(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColour(currentColour)
end
return graphic
 
