local file = {}
 
function file.split (inputstr, sep)
        SkyOS.sLog.info("[file] splitting " .. inputstr)
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
  SkyOS.sLog.info("[file] loading image " .. path)
  local grpFile = fs.open(path,"r")
  
  for i = 1,file.countLines(path),1 do
    local grpLine = grpFile.readLine()
    local grpTable = file.split(grpLine,",")
    local operation = grpTable[1]
    if operation == "P" then
      SkyOS.lib.graphic.drawPixel(grpTable[2],grpTable[3],tonumber(grpTable[4]),tOutput)
    elseif operation == "B" then
      SkyOS.lib.graphic.drawBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]),tOutput)
    elseif operation == "F" then
      SkyOS.lib.graphic.drawFilledBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]),tOutput)
    elseif operation == "L" then
      SkyOS.lib.graphic.drawLine(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]),tOutput)
    elseif operation == "TEXT" then
      SkyOS.lib.graphic.drawText(grpTable[2],grpTable[3],grpTable[4],grpTable[5],grpTable[6],tOutput)
    end
    
  end
  SkyOS.sLog.info("[file] done loading, closing file.")
  grpFile.close()
end

function file.loadAppGraphics(graphicPath,settingsPath,appName)
  SkyOS.sLog.info("[file] loading app " .. appName .. ", graphic at " .. graphicPath .. ", setting " .. settingsPath)
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
  SkyOS.sLog.info("[info] offset " .. x .."X, " .. y "Y")
  SkyOS.sLog.info("[info] loading image")
  for i = 1,file.countLines(graphicPath),1 do
    local grpLine = graphicFile.readLine()
    local grpTable = file.split(grpLine,",")
    local operation = grpTable[1]
    local a = tonumber(grpTable[2])+x
    local b = tonumber(grpTable[3])+y
    if operation == "P" then
      SkyOS.lib.graphic.drawPixel(a,b,tonumber(grpTable[4]))
    elseif operation == "B" then
      local c = tonumber(grpTable[4])+x
      local d = tonumber(grpTable[5])+y
      SkyOS.lib.graphic.drawBox(a,b,c,d,tonumber(grpTable[6]))
    elseif operation == "F" then
      graphic.drawFilledBox(a,b,c,d,tonumber(grpTable[6]))
    elseif operation == "L" then
      SkyOS.lib.graphic.drawLine(a,b,c,d,tonumber(grpTable[6]))
    elseif operation == "TEXT" then
      SkyOS.lib.graphic.drawText(a,b,grpTable[4],grpTable[5],grpTable[6])
    end
  end
  settingsFile.close()
  graphicFile.close()
end

function file.loadApps(settingsFile)
  SkyOS.sLog.info("[info] loading all apps")
  local settings = fs.open(settingsFile,"r")
  local lines = file.countLines(settingsFile)
  for i = 1, lines, 1 do
    local line = settings.readLine()
    local lineTable = file.split(line,",")
    local app = lineTable[1]
    local appGraphicLocation = fs.combine("/graphics/app/",app)
    if fs.exists(appGraphicLocation) then
      file.loadAppGraphics(appGraphicLocation,settingsFile,app)
    end
  end
  settings.close()
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
