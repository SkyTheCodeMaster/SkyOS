local time = os.time()
local formattedTime = textutils.formatTime(time, true)
term.setCursorPos(22,20)
term.write(formattedTime)
