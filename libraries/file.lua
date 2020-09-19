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
  return file.split(grpLine,",")
end
return file
