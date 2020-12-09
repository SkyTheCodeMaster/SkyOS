local graphic = {}
 
-- Graphics library for SkyOS
 
local to_colors, to_blit = {}, {}
for i = 1, 16 do
    to_blit[2^(i-1)] = ("0123456789abcdef"):sub(i, i)
    to_colors[("0123456789abcdef"):sub(i, i)] = 2^(i-1)
end

function graphic.drawFilledBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local currentX,currentY = tOutput.getCursorPos()
  local col = to_blit[nC]
  local w = (tonumber(nX2)-tonumber(nX1))+1
  for i=tonumber(nY1),tonumber(nY2) do
    tOutput.setCursorPos(tonumber(nX1),i)
    tOutput.blit(string.rep(" ",w),string.rep(col,w),string.rep(col,w))
  end
  tOutput.setCursorPos(currentX,currentY)
end
 
function graphic.drawBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = term.getTextColour()
  local nCurBG = term.getBackgroundColour()
  local nCurX, nCurY = term.getCursorPos()
  
  paintutils.drawBox(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nC))
  
  term.setCursorPos(nCurX,nCurY)
  term.setTextColour(nCurFG)
  term.setBackgroundColour(nCurBG)
end
 
function graphic.drawPixel(nX,nY,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = term.getTextColour()
  local nCurBG = term.getBackgroundColour()
  local nCurX, nCurY = term.getCursorPos()
  
  paintutils.drawPixel(tonumber(nX),tonumber(nY),tonumber(nC))
  
  term.setCursorPos(nCurX,nCurY)
  term.setTextColour(nCurFG)
  term.setBackgroundColour(nCurBG)
end
 
function graphic.drawText(nX,nY,nFG,nBG,sText,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = term.getTextColour()
  local nCurBG = term.getBackgroundColour()
  local nCurX, nCurY = term.getCursorPos()
    
  term.setCursorPos(tonumber(nX),tonumber(nY))
  term.setTextColour(tonumber(nFG))
  term.setBackgroundColour(tonumber(nBG))
  term.write(sText)
    
  term.setCursorPos(nCurX,currentY)
  term.setTextColour(nCurFG)
  term.setBackgroundColour(nCurBG)
end

function graphic.drawLine(nX1, nY1, nX2, nY2, nCol, tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = term.getTextColour()
  local nCurBG = term.getBackgroundColour()
  local nCurX, nCurY = term.getCursorPos()
 
  paintutils.drawLine(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nCol))
 
  term.setCursorPos(nCurX,nCurY)
  term.setTextColour(nCurFG)
  term.setBackgroundColour(nCurBG)
end

return graphic
