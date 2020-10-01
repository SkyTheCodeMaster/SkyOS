graphic = require("libraries.graphic")
local file = {}
 
function file.split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
 
function file.countLines(path)
 
  local lines = 0 
  for _ in io.lines(path) do lines = lines + 1 end 
  return lines
  
end
 
function file.loadGrpLines(path)
 
  local grpFile = fs.open(path,"r")
  local lines = file.countLines(path)
  
  for i = 1,file.countLines(path),1 do
    local grpLine = grpFile.readLine()
    local grpTable = file.split(grpLine,",")
    local operation = grpTable[1]
    if operation == "P" then
      graphic.drawPixel(grpTable[2],grpTable[3],tonumber(grpTable[4]))
    elseif operation == "B" then
      graphic.drawBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]))
    elseif operation == "F" then
      graphic.drawFilledBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]))
    elseif operation == "L" then
      graphic.drawLine(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]))
    elseif operation == "TEXT" then
      graphic.drawText(grpTable[2],grpTable[3],grpTable[4],grpTable[5],grpTable[6])
    end
    
  end
  grpFile.close()
end

function file.loadAppGraphics(graphicPath,settingsPath,appName)
  local graphicFile = fs.open(graphicPath,"r")
  local settingsFile = fs.open(settingsPath,"r")
  local x,y
  for i = 1,file.countLines(settingsPath),1 do
    local settingsLines = settingsFile.readLine()
    local settingsTable = file.split(settingsLines,",")
    local app = settingsTable[1]
    if app == appName then
      x,y = settingsTable[2],settingsTable[3]
    end
  end
  for i = 1,file.countLines(graphicPath),1 do
    local grpLine = graphicFile.readLine()
    local grpTable = file.split(grpLine,",")
    local operation = grpTable[1]
    local a = tonumber(grpTable[2])+x
    local b = tonumber(grpTable[3])+y
    if operation == "P" then
      graphic.drawPixel(a,b,tonumber(grpTable[4]))
    elseif operation == "B" then
      local c = tonumber(grpTable[4])+x
      local d = tonumber(grpTable[5])+y
      graphic.drawBox(a,b,c,d,tonumber(grpTable[6]))
    elseif operation == "F" then
      graphic.drawFilledBox(a,b,c,d,tonumber(grpTable[6]))
    elseif operation == "L" then
      graphic.drawLine(a,b,c,d,tonumber(grpTable[6]))
    elseif operation == "TEXT" then
      graphic.drawText(a,b,grpTable[4],grpTable[5],grpTable[6])
    end
  end
end
return file
 
