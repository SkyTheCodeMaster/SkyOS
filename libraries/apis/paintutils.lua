local expect = require("cc.expect")

local function drawPixelInternal(xPos, yPos)
    term.setCursorPos(xPos, yPos)
    term.write(" ")
end

local function toBlit(color)
  local idx = select(2, math.frexp(color))
  return ("0123456789abcdef"):sub(idx, idx)
end

local function drawPixelInternal(nX,nY,nsCol,tOutput)
  tOutput = tOutput or term.current()
  if type(nsCol) == "number" then nCol = toBlit(nsCol) end
  local fg = toBlit(tOutput.getTextColour())
  term.setCursorPos(nX,nY)
  term.blit(" ",fg,nsCol)
end

local tColourLookup = {}
for n = 1, 16 do
    tColourLookup[string.byte("0123456789abcdef", n, n)] = 2 ^ (n - 1)
end

-- Sorts pairs of startX/startY/endX/endY such that the start is always the min
local function sortCoords(startX, startY, endX, endY)
    local minX, maxX, minY, maxY

    if startX <= endX then
        minX, maxX = startX, endX
    else
        minX, maxX = endX, startX
    end

    if startY <= endY then
        minY, maxY = startY, endY
    else
        minY, maxY = endY, startY
    end

    return minX, maxX, minY, maxY
end

function drawPixel(xPos, yPos, colour)
    expect(1, xPos, "number")
    expect(2, yPos, "number")
    expect(3, colour, "number", "nil")

    if colour then
        term.setBackgroundColor(colour)
    end
    return drawPixelInternal(xPos, yPos)
end

function drawLine(startX, startY, endX, endY, colour)
    expect(1, startX, "number")
    expect(2, startY, "number")
    expect(3, endX, "number")
    expect(4, endY, "number")
    expect(5, colour, "number", "nil")

    startX = math.floor(startX)
    startY = math.floor(startY)
    endX = math.floor(endX)
    endY = math.floor(endY)

    if colour then
        term.setBackgroundColor(colour)
    end
    if startX == endX and startY == endY then
        drawPixelInternal(startX, startY)
        return
    end

    local minX, maxX, minY, maxY = sortCoords(startX, startY, endX, endY)

    -- TODO: clip to screen rectangle?

    local xDiff = maxX - minX
    local yDiff = maxY - minY

    if xDiff > math.abs(yDiff) then
        local y = minY
        local dy = yDiff / xDiff
        for x = minX, maxX do
            drawPixelInternal(x, math.floor(y + 0.5))
            y = y + dy
        end
    else
        local x = minX
        local dx = xDiff / yDiff
        if maxY >= minY then
            for y = minY, maxY do
                drawPixelInternal(math.floor(x + 0.5), y)
                x = x + dx
            end
        else
            for y = minY, maxY, -1 do
                drawPixelInternal(math.floor(x + 0.5), y)
                x = x - dx
            end
        end
    end
end

function drawBox(startX, startY, endX, endY, nColour)
    expect(1, startX, "number")
    expect(2, startY, "number")
    expect(3, endX, "number")
    expect(4, endY, "number")
    expect(5, nColour, "number", "nil")

    startX = math.floor(startX)
    startY = math.floor(startY)
    endX = math.floor(endX)
    endY = math.floor(endY)

    if nColour then
        term.setBackgroundColor(nColour) -- Maintain legacy behaviour
    else
        nColour = term.getBackgroundColour()
    end
    local colourHex = colours.toBlit(nColour)

    if startX == endX and startY == endY then
        drawPixelInternal(startX, startY)
        return
    end

    local minX, maxX, minY, maxY = sortCoords(startX, startY, endX, endY)
    local width = maxX - minX + 1

    for y = minY, maxY do
        if y == minY or y == maxY then
            term.setCursorPos(minX, y)
            term.blit((" "):rep(width), colourHex:rep(width), colourHex:rep(width))
        else
            term.setCursorPos(minX, y)
            term.blit(" ", colourHex, colourHex)
            term.setCursorPos(maxX, y)
            term.blit(" ", colourHex, colourHex)
        end
    end
end

function drawFilledBox(startX, startY, endX, endY, nColour)
    expect(1, startX, "number")
    expect(2, startY, "number")
    expect(3, endX, "number")
    expect(4, endY, "number")
    expect(5, nColour, "number", "nil")

    startX = math.floor(startX)
    startY = math.floor(startY)
    endX = math.floor(endX)
    endY = math.floor(endY)

    if nColour then
        term.setBackgroundColor(nColour) -- Maintain legacy behaviour
    else
        nColour = term.getBackgroundColour()
    end
    local colourHex = colours.toBlit(nColour)

    if startX == endX and startY == endY then
        drawPixelInternal(startX, startY)
        return
    end

    local minX, maxX, minY, maxY = sortCoords(startX, startY, endX, endY)
    local width = maxX - minX + 1

    for y = minY, maxY do
        term.setCursorPos(minX, y)
        term.blit((" "):rep(width), colourHex:rep(width), colourHex:rep(width))
    end
end
