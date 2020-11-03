if fs.exists("libraries/graphic.lua") then
  graphic = require("libraries.graphic")
end
local file = {}
 
function file.split (inputstr, sep)
        sLog.info("[file] splitting " .. inputstr)
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
  sLog.info("[file] counting lines " .. path)
  local lines = 0 
  for _ in io.lines(path) do lines = lines + 1 end 
  sLog.info("[file] " .. path .. " has " .. tostring(lines))
  return lines
  
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
