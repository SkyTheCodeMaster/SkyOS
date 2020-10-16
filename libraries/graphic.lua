local graphic = {}
 
-- Graphics library for SkyOS
 
function graphic.drawFilledBox(arg1, arg2, arg3, arg4, arg5)
--arg1 is top left x
--arg2 is top left y
--arg3 bottom right x
--arg4 is bottom right y
--arg5 is color (colors.black)
    currentColour = term.getBackgroundColour()
    currentTextColour = term.getTextColour()
    currentX, currentY = term.getCursorPos()
 
    paintutils.drawFilledBox(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))
 
    
    term.setTextColour(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColour(currentColour)
    
end
 
local to_colors, to_blit = {}, {}
for i = 1, 16 do
    to_blit[2^(i-1)] = ("0123456789abcdef"):sub(i, i)
    to_colors[("0123456789abcdef"):sub(i, i)] = 2^(i-1)
end
function graphic.drawBox(x1,y1,x2,y2,c) -- (bg and fg provided in blit format)
  local col = to_blit{c}
  local w = (x2-x1)+1
  for i=y1,y2 do
    term.setCursorPos(x1,i)
    term.blit(string.rep(" ",w),string.rep(col,w),string.rep(col,w))
  end
end
 
function graphic.drawPixel(arg1, arg2, arg3)
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
 
