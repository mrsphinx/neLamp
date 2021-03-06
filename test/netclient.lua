local module={}
local client = nil
-- command to server:
-- ID:REGISTER:ID - registation on the server to self ID
-- ID:SUBSCRIBE:EVENT - subscribe to the event on the server
-- ID:UNSUBSCRIBE:EVENT - unsubscribe to the event on the server
-- ID:PING:PING - ping-pong
-- command from server:
-- ID:REGISTER:REGISTERED
-- ID:COMMAND:EVENT - the command came from the server
-- ID:PING:PONG - ping-pong

local function ping_pong()
    if client then
        client:send(config.ID..":PING:PING")
    end
end

local function parse_receive_msg(msg)
    local id,k,v = string.match(msg,"^(.+):(.+):(.+)$")
    if tonumber(config.ID)==tonumber(id) then
        if k and v then
            if k == "REGISTER" or k == "COMMAND" or k == "PING" then
                local evt = events.getEvents(v)
                if evt and evt.enabled==1 then
                    evt:f()
                   
                end
            end
        end
    else
        print("ID:"..id.."\tconfig.id:"..config.ID)
    end
end

local function net_start()
    client = websocket.createClient()
    client:on("connection", function(ws)
        tmr.unregister(0)
        print('got ws connection')
        client:send(config.ID..":REGISTER:"..config.ID)
        tmr.alarm(1,5000,1,ping_pong)
    end)
    client:on("receive", function(_, msg, opcode)
        print('got message:', msg, opcode) -- opcode is 1 for text message, 2 for binary
        if opcode==1 then
            parse_receive_msg(msg)
        end
    end)
    client:on("close", function(_, status)
        print('connection closed', status)
        client = nil -- required to Lua gc the websocket client
        tmr.alarm(0,10000,1,net_start)
        tmr.unregister(1)
    end)
      
      client:connect("ws://"..config.HOST..":"..config.PORT)
      
end

function module.start()
    net_start()
end

return module


