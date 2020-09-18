require("libraries.file")
local graphic = {}

-- Graphics library for SkyOS

function graphic.drawFilledBox(arg1, arg2, arg3, arg4, arg5)
--arg1 is top left x
--arg2 is top left y
--arg3 bottom right x
--arg4 is bottom right y
--arg5 is color (colors.black)
    currentColour = term.getBackgroundColor()
    currentTextColour = term.getTextColor()
    currentX, currentY = term.getCursorPos()
 
    paintutils.drawFilledBox(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))
 
    
    term.setTextColor(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColor(currentColour)
    
end
 
function graphic.drawBox(arg1, arg2, arg3, arg4, arg5)
--arg1 is top left x
--arg2 is top left y
--arg3 bottom right x
--arg4 is bottom right y
--arg5 is color (colors.black)
    currentColour = term.getBackgroundColor()
    currentTextColour = term.getTextColor()
    currentX, currentY = term.getCursorPos()
 
    paintutils.drawBox(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))

    
    term.setTextColor(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColor(currentColour)
end

function graphic.drawPixel(arg1, arg2, arg3)
--arg1 is x
--arg2 is y
--arg3 is color (colors.black)
    currentColour = term.getBackgroundColor()
    currentTextColour = term.getTextColor()
    currentX, currentY = term.getCursorPos()
    
    paintutils.drawPixel(tonumber(arg1),tonumber(arg2),tonumber(arg3))
    
    term.setTextColor(currentTextColour)
    term.setCursorPos(currentX,currentY)
    term.setBackgroundColor(currentColour)
    
end
 
return graphic
