-- gps wrapper library incase if the normal gps library is not present on pc. this originiated from craftos-pc's lack of the gps library because you can not have gps on it.
 
-- if the gps library is not found it will return default values of 1,1,1
 
gpswrapper = {}
 
function gpswrapper.gpslocate(timeout)
    if fs.exists("rom/apis/gps.lua") then
        gps.locate(timeout)
    else
        return 1,1,1
    end
end
 
return gpswrapper
