local graphic = {}
-- Graphics library for SkyOS
function graphic.drawFilledBox(arg1, arg2, arg3, arg4, arg5)
    currentColour = term.getBackgroundColor()
    currentTextColour = term.getTextColor()
 
    paintutils.drawFilledBox(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))
 
    term.setBackgroundColor(currentColour)
    term.setTextColor(currentTextColour)
end
 
function graphic.drawBox(arg1, arg2, arg3, arg4, arg5)
    currentColour = term.getBackgroundColor()
    currentTextColour = term.getTextColor()
 
    paintutils.drawBox(tonumber(arg1),tonumber(arg2),tonumber(arg3),tonumber(arg4),tonumber(arg5))
 
    term.setBackgroundColor(currentColour)
    term.setTextColor(currentTextColour)
end
 
return graphic
