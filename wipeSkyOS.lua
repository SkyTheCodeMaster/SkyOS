if fs.exists("graphics/") then
    fs.delete("graphics/")
end
if fs.exists("libraries/") then
    fs.delete("libraries")
end
if fs.exists("startup.lua") then
    fs.delete("startup.lua")
end
if fs.exists("customPrograms/") then
  fs.delete("customPrograms/")
end
if fs.exists("wipeSkyOS.lua") then
    fs.delete("wipeSkyOS.lua")
shell.run("gitget SkyTheCodeMaster SkyOS master")
os.reboot()
