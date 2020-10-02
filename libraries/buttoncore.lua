local buttons = {}
local public = {}
 
local function randomId()
    local id = ""
    for i = 1, 8 do
        id = id .. string.char(math.random(0, 255))
    end
    return id
end
 
local function expect(argNum, value, required)
    if type(value) ~= required then
        error(("bad argument %d: expected %s, got %s"):format(argNum, required, type(value)))
    end
end
 
function public.new(x, y, w, h, f, m)
    expect(1, x, "number")
    expect(2, y, "number")
    expect(3, w, "number")
    expect(4, h, "number")
    expect(5, f, "function")
 
    if not m then m = 1 end
 
    local id = randomId()
    buttons[id] = {
        x = x,
        y = y,
        w = w,
        h = h,
        f = f, -- function
        m = m -- mouse
    }
    return id
end
 
function public.remove(id)
    if buttons[id] then
        buttons[id] = nil
    else
        expect(1, "string", id)
        error("ID does not exist!")
    end
end
 
function public.checkEvents(e)
    if e[1] == "mouse_click" then
        local m, x, y = e[2], e[3], e[4]
        for i, v in pairs(buttons) do
            if m == v.m and x >= v.x and x <= v.x + v.w - 1 and y >= v.y and y <= v.y + v.h - 1 then
                print(x, y)
                v.f()
            end
        end
    end
end
 
function public.eventLoop()
    while true do
        public.checkEvents({os.pullEvent()})
    end
end
 
return public
