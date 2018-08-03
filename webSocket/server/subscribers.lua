local module = {}

local _subscribe = {}

function module.subscribe(...)
    local id, evt,socket = ...
    print("subscribe")
    print(socket)
    if id and evt then
        if not _subscribe["evt" .. evt] then
            _subscribe["evt" .. evt]={}    
        end
        local  key = "id"..id
            _subscribe["evt" .. evt][key] = socket
        
    end
end

function module.unsubscribe(...)
    local id, evt = ...
    if id and evt then
        for k,a in pairs(_subscribe["evt"..evt]) do 
            if k == id then
                _subscribe["evt"..evt]["id"..id]=nil
            end
        end

    end
    collectgarbage()
end


function module.get()
    return _subscribe
end

local function getl(T)
    local count=0
    for _ in pairs(T) do count = count +1 end
    return count
 end

function module.isempty()
    local length =  getl(_subscribe)
    if length > 0 then
        return false
    else
        return true
    end
end
return module
