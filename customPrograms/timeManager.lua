local time = os.time()
while true do
  local formattedTime = textutils.formatTime(time, true)
  term.setCursorPos(22,20)
  term.setBackgroundColour(colours.grey)
  term.write(formattedTime)
  term.setBackgroundColour(colours.black)
end
