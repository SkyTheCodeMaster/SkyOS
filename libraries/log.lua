local mLog
local LFT = {} -- Log File Table
local log = {}

function log.new(logPath,logName)
  LFT[tostring(logName)] = fs.open(logPath,"a")
end

function log.save(logName)
  if logName == nil then logName = mLog end
  LFT[logName].flush()
end

function log.close(logName)
  if logName == nil then logName = mLog end
  LFT[logName].close()
end

function log.info(text,logName)
  if logName == nil then logName = mLog end
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [INFO] "..tostring(text))
end

function log.warn(text,logName)
  if logName == nil then logName = mLog end
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [WARN] "..tostring(text))
end

function log.error(errorID,errorInfo,logName)
  if logName == nil then logName = mLog end
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [ERROR] "..tostring(errorID)..":"..tostring(errorInfo))
end

function log.errorC(errorID,errorInfo,logName)
  if logName == nil then logName = mLog end
  log.error(errorID,errorInfo,logName)
  log.save(logName)
  log.close(logName)
  error(tostring(errorInfo).." See log for more")
end
  
function log.setMain(logName)
  mLog = logName
end

return log
