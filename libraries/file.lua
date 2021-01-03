
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
 
function file.loadGrpLines(path,tOutput)
  tOutput = tOutput or term.current()
  local grpFile = fs.open(path,"r")
  
  for i = 1,file.countLines(path),1 do
    local grpLine = grpFile.readLine()
    local grpTable = file.split(grpLine,",")
    local operation = grpTable[1]
    if operation == "P" then
      graphic.drawPixel(grpTable[2],grpTable[3],tonumber(grpTable[4]),tOutput)
    elseif operation == "B" then
      graphic.drawBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]),tOutput)
    elseif operation == "F" then
      graphic.drawFilledBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]),tOutput)
    elseif operation == "L" then
      graphic.drawLine(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]),tOutput)
    elseif operation == "TEXT" then
      graphic.drawText(grpTable[2],grpTable[3],grpTable[4],grpTable[5],grpTable[6],tOutput)
    elseif operation == "PAL" then
      term.setPaletteColour(tonumber(grpTable[2]),grpTable[3])
    end
    
  end
  grpFile.close()
end

function file.getSize(path)
  local size = 0
  local files = fs.list(path)
  for i=1,#files do
    if fs.isDir(fs.combine(path, files[i])) then
      size = size + file.getSize(fs.combine(path, files[i]))
    else
      size = size + fs.getSize(fs.combine(path, files[i]))
    end
  end
  return size
end

return file
