local module = {}

function err (x)
    print ("err called", x)
    return "oh no!"
  end -- err

local function modeSOFTAP()
    wifi.setmode(wifi.SOFTAP)
    wifi.eventmon.register(
        wifi.eventmon.AP_STACONNECTED,
        function(T)
            print("\n\tAP -> STATION CONNECTED" .. "\n\tMAC: " .. T.MAC .. "\n\tAID: " .. T.AID)
            local ip, nm, gw = wifi.ap.getip()
            print("\n\tIP:" .. ip .. "\tmask:" .. nm .. "\tGW:" .. gw)
            
            local ok,err,msg = xpcall(events.STACONNECTED,err)
            if ok then
                -- config.netClient = net.createConnection(net.TCP, 0)
                -- config.netClient:on("receive", function(sck, c) print(c) end)
                -- config.netClient:on("connection", function(sck, c) print(c) end)
            else
                print("ERROR netSocket:"..msg)
            end
        end
    )
    wifi.ap.config({ssid = config.SSID, pwd = config.PASSWORD})
end

local function configLED()
    -- configure LED and Button
    gpio.mode(config.LEDRedPin, gpio.OUTPUT)
    gpio.write(config.LEDRedPin, gpio.LOW)
    gpio.mode(config.LEDGreenPin, gpio.OUTPUT)
    gpio.write(config.LEDGreenPin, gpio.LOW)

    gpio.mode(config.BUTTON, gpio.INPUT)
    local fn = events.interuptButton
    gpio.trig(config.BUTTON, "up", fn)
end

function module.start()
    print("Configuring Wifi ...")
    configLED()
    modeSOFTAP()
end

return module
