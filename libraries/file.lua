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
    elseif operation == "TEXT" then
      graphic.drawText(grpTable[2],grpTable[3],grpTable[4],grpTable[5])
    end
    
  end
  
end
return file
