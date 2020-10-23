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

function log.error(text,logName)
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[logName].writeLine(curTime.." [ERROR] "..tostring(text))
end

return log
