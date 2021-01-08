local graphic = {}
 
-- Graphics library for SkyOS
 
local to_colors, to_blit = {}, {}
for i = 1, 16 do
    to_blit[2^(i-1)] = ("0123456789abcdef"):sub(i, i)
    to_colors[("0123456789abcdef"):sub(i, i)] = 2^(i-1)
end

-- Temp removal to maybe fix it
--[[ function graphic.drawFilledBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local currentX,currentY = tOutput.getCursorPos()
  local col = to_blit[nC]
  local w = (tonumber(nX2)-tonumber(nX1))+1
  for i=tonumber(nY1),tonumber(nY2) do
    tOutput.setCursorPos(tonumber(nX1),i)
    tOutput.blit(string.rep(" ",w),string.rep(col,w),string.rep(col,w))
  end
  tOutput.setCursorPos(currentX,currentY)
end]]

function graphic.drawFilledBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
  
  paintutils.drawFilledBox(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nC),tOutput)
  
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end
 
function graphic.drawBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
  
  paintutils.drawBox(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nC),tOutput)
  
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end
 
function graphic.drawPixel(nX,nY,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
  
  paintutils.drawPixel(tonumber(nX),tonumber(nY),tonumber(nC),tOutput)
  
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end
 
function graphic.drawText(nX,nY,nFG,nBG,sText,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
    
  tOutput.setCursorPos(tonumber(nX),tonumber(nY))
  tOutput.setTextColour(tonumber(nFG))
  tOutput.setBackgroundColour(tonumber(nBG))
  tOutput.write(sText)
    
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end

function graphic.drawLine(nX1, nY1, nX2, nY2, nCol, tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
 
  paintutils.drawLine(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nCol),tOutput)
 
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end

return graphic
