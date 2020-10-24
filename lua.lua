 
local tArgs = { ... }
 
local pretty = require "cc.pretty"
 
local bRunning = true
local tCommandHistory = {}
local tEnv = {
    ["exit"] = function()
        bRunning = false
    end,
    ["_echo"] = function( ... )
        return ...
    end,
}
setmetatable( tEnv, { __index = _ENV } )
 
-- Replace our package.path, so that it loads from the current directory, rather
-- than from /rom/programs. This makes it a little more friendly to use and
-- closer to what you'd expect.
-- Borrowed from [CC: Tweaked](https://github.com/SquidDev/CC-Tweaked)
if shell then
    local dir = shell.dir()
    if dir:sub(1, 1) ~= "/" then dir = "/" .. dir end
    if dir:sub(-1) ~= "/" then dir = dir .. "/" end
 
    local strip_path = "?;?.lua;?/init.lua;"
    local path = package.path
    if path:sub(1, #strip_path) == strip_path then
        path = path:sub(#strip_path + 1)
    end
 
    package.path = dir .. "?;" .. dir .. "?.lua;" .. dir .. "?/init.lua;" .. path
end
 
if term.isColour() then
    term.setTextColour( colours.yellow )
end
local librariesAdded = "sLog, "
local function loadLib(lib)
  libExists = string.gsub(lib,"%.","/")
  if fs.exists(libExists..".lua") then
    loadedLib = require(lib)
    sLog.info("[sLua] loaded library " .. lib)
    librariesAdded = librariesAdded..string.upper(lib)..", "
  end
end
print("SkyLua " .. versions.sLua)
file = loadLib("libraries.file")
graphic = loadLib("libraries.graphic")
gpswrapper = loadLib("libraries.gpswrapper")
print("Added libraries: " .. librariesAdded)
term.setTextColour( colours.white )

 
while bRunning do
    --if term.isColour() then
    --    term.setTextColour( colours.yellow )
    --end
    write( "sLua> " )
    --term.setTextColour( colours.white )
 
    local s = read( nil, tCommandHistory, function( sLine )
        if settings.get( "lua.autocomplete" ) then
            local nStartPos = string.find( sLine, "[a-zA-Z0-9_%.:]+$" )
            if nStartPos then
                sLine = string.sub( sLine, nStartPos )
            end
            if #sLine > 0 then
                return textutils.complete( sLine, tEnv )
            end
        end
        return nil
    end )
    if s:match("%S") and tCommandHistory[#tCommandHistory] ~= s then
        table.insert( tCommandHistory, s )
    end
    if settings.get("lua.warn_against_use_of_local") and s:match("^%s*local%s+") then
        if term.isColour() then
            term.setTextColour(colours.yellow)
        end
       print("To access local variables in later inputs, remove the local keyword.")
       term.setTextColour(colours.white)
    end
    
    local nForcePrint = 0
    local func, e = load( s, "=lua", "t", tEnv )
    local func2, e2 = load( "return _echo("..s..");", "=lua", "t", tEnv )
    if not func then
        if func2 then
            func = func2
            e = nil
            nForcePrint = 1
        end
    else
        if func2 then
            func = func2
        end
    end
    
    if func then
        local tResults = table.pack( pcall( func ) )
        if tResults[1] then
            local n = 1
            while n < tResults.n or (n <= nForcePrint) do
                local value = tResults[ n + 1 ]
                local ok, serialised = pcall(pretty.pretty, value, {
                    function_args = settings.get("lua.function_args"),
                    function_source = settings.get("lua.function_source"),
                })
                if ok then
                    pretty.print(serialised)
                else
                    print( tostring( value ) )
                end
                n = n + 1
            end
        else
            printError( tResults[2] )
        end
    else
        printError( e )
    end
    
end
 
