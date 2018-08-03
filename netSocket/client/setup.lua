local module = {}

 module.srv=nil

function err(x)
    print("err called", x)
    return "oh no!"
end -- err

local function modeSTATION()
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid = config.SSID, pwd = config.PASSWORD})
    wifi.eventmon.register(
        wifi.eventmon.STA_GOT_IP,
        function(T)
            print("\n====================================")
            print(
                "\n\tSTA - GOT IP" ..
                    "\n\tStation IP: " .. T.IP .. "\n\tSubnet mask: " .. T.netmask .. "\n\tGateway IP: " .. T.gateway
            )
            print("====================================")
            module.srv = net.createServer(net.TCP, 28000)
            -- tmr.alarm(3,200,tmr.ALARM_AUTO,function() 
                local ok, err, msg = xpcall(module.createNetServer, err)
                if ok then
                else
                    print("ERROR WebSocket:" )
                    print( msg)
                end
            -- end)
        end
    )
    return true
end

function module.receiver(sck, data)
    print(node.heap())
    print(data)
    collectgarbage("collect")
    print(node.heap())
    -- sck:close()
end

function module.createNetServer()
    print("create server")
    -- module.srv = net.createServer(net.TCP, 28000)

    if module.srv then
        tmr.stop(3)
        print(node.heap())
        module.srv:listen(
            config.PORT,
            function(conn)
                conn:on("receive", module.receiver)
                conn:on("connection",function(sck) 
                    print("CONNECTED") 
                    print(node.heap())
                    -- conn:send("hello world")
                end )
                conn:on("reconnection", function(sck)  print("reconnect") end)
                conn:on("disconnection", function(sck)  print("disconnect") end)
                conn:on("sent",function(sck) print("sent") end)
            end
        )
    end
end

function module.start()
    print("Configuring Wifi ...")
    local ok, err, msg = xpcall(modeSTATION, err)
    if ok then
    else
        print("ERROR WebSocket:" .. msg)
    end
    -- modeSTATION()
    print("\nOK\n")
end

return module
