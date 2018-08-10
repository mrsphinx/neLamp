local module = {}

module.sock = nil
module.mac = {}
module.count=10
function err(x)
    print("err called", x)
    return "oh no!"
end -- err

function module.init()
    wifi.setmode(wifi.SOFTAP)
    wifi.eventmon.register(
        wifi.eventmon.AP_STACONNECTED,
        function(T)
            print("\n\tAP -> STATION CONNECTED" .. "\n\tMAC: " .. T.MAC .. "\n\tAID: " .. T.AID)
            local ip, nm, gw = wifi.ap.getip()
            print("\n\tIP:" .. ip .. "\tmask:" .. nm .. "\tGW:" .. gw)
            -- module.sock = net.createConnection(net.TCP, 0)
            if not module.sock then
                module.sock = net.createUDPSocket()
            end
            module.mac[T.MAC] = 0
        end
    )
    wifi.ap.config({ssid = config.SSID, pwd = config.PASSWORD})
    tmr.alarm(4,1000,tmr.ALARM_SINGLE, function()
        -- if not httpserver.server then
            httpserver.init()
        -- end
    end)
end

function module.sendCustomBroadcast(msg, fn, blnk)
    if module.sock then
        local bip = wifi.ap.getbroadcast()
        module.sock:on(
            "receive",
            function(s, data, port, ip)
                local act, mac = string.match(data, "^(.+)-(.+)$")
                if act ~= msg then
                    print(data)
                else
                    local flg = false
                    for k, v in pairs(module.mac) do
                        if k == mac then
                            module.mac[k] = 1
                        end
                        if module.mac[k] == 0 then
                            flg = true
                        end
                    end
                    if flg == true and module.count > 0 then
                        tmr.alarm(
                            4,
                            500,
                            tmr.ALARM_SINGLE,
                            function()
                                if module.count == 0 then
                                    tmr.stop(4)
                                    fn()
                                else
                                    module.count = module.count-1
                                    module.sock:send(config.PORT, bip, msg)
                                end
                            end
                        )
                    else
                        fn()
                    end
                end
                print(string.format("received '%s' from %s:%d", data, ip, port))
            end
        )
        -- module.sock:connect(config.PORT, bip)
        -- module.sock:send(msg)
        module.sock:send(config.PORT, bip, msg)
        port, ip = module.sock:getaddr()
        print(string.format("local UDP socket address / port: %s:%d", ip, port))
    -- module.sock:close()
    end
end

function module.start()
    print("Configuring Wifi ...")
    config.confLED(events.interuptButton)
    module.init()
end

return module
