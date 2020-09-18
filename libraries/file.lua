local file = {}

function file.listFiles(path)
  fs.list(path)
end

function file.size(path)
  fs.getSize(path)
end

function file.readGraphicsFile(path)
  if fs.exists(path)==true then
    local skgrp = fs.open(path, "r")
    
    skgrp.close()
  else
    error("FileAPI readGraphicsFile: requested file does not exist.")
  end
end

return file
