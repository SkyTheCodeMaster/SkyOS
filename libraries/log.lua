local LFT = {} -- Log File Table
local log = {}

function log.new(logPath,logName)
  LFT[logName] = fs.open(logPath,"a")
end

function log.save(logName)
  LFT[logName].flush()
end

function log.close(logName)
  LFT[logName].close()
end

function log.info(text,logName)
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [INFO] "..tostring(text))
end

function log.warn(text,logName)
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [WARN] "..tostring(text))
end

function log.error(errorID,errorInfo,logName)
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [ERROR] "..tostring(errorID)..":"..tostring(errorInfo))
end

function log.errorC(errorID,errorInfo,logName)
  log.error(errorID,errorInfo,logName)
  log.save(logName)
  log.close(logName)
  error(tostring(errorInfo).." See log for more")
end

return log
