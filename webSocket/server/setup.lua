local module = {}

local function wifi_wait_ip()
    if wifi.sta.getip() == nil then
        print("IP unavailable, Waiting...")
    else
        tmr.stop(1)
        print("\n====================================")
        print("ESP8266 mode is: " .. wifi.getmode())
        print("MAC address is: " .. wifi.ap.getmac())
        print("IP is " .. wifi.sta.getip())
        print("====================================")
        local ip, nm, gw = wifi.ap.getip()
        config.HOST = gw
        app.start()
    end
end


function err (x)
    print ("err called", x)
    return "oh no!"
  end -- err

local function modeSOFTAP()
    wifi.setmode(wifi.SOFTAP)
    wifi.eventmon.register(
        wifi.eventmon.AP_STACONNECTED,
        function(T)
            print("\n\tAP - STATION CONNECTED" .. "\n\tMAC: " .. T.MAC .. "\n\tAID: " .. T.AID)
            local ip, nm, gw = wifi.ap.getip()
            print("\n\tIP:" .. ip .. "\tmask:" .. nm .. "\tGW:" .. gw)
            local table = {}
            table = wifi.ap.getclient()
            for mac, ip in pairs(table) do
                print(mac, ip)
            end
            local ok,err,msg = xpcall(app.start,err)
            if ok then
    
            else
                print("ERROR WebSocket:"..msg)
            end
        end
    )
    wifi.ap.config({ssid = config.SSID, pwd = config.PASSWORD})
end

local ledON = nil
local debounceDelay, debounceAlarmId, trig = 100, 5, gpio.trig


local function interuptButton(level, pulse1)
    trig(config.BUTTON, "none")
    if subscribers.isempty() == false then
        print("LEVEL:" .. level, "\tWHEN:" .. pulse1)
        if ledON then
            gpio.write(ledON, gpio.LOW)
            if ledON == config.LEDGreenPin then
                ledON = config.LEDRedPin
            else
                ledON = config.LEDGreenPin
            end
        else
            ledON = config.LEDGreenPin
        end

        local subsc = subscribers.get()
        for _ in pairs(subsc) do
            local eventTable = subsc[ _ ];
            for k1 in pairs(eventTable) do
                if ledON == config.LEDGreenPin then
                    eventTable[k1].send(string.sub(k1,3)..":COMMAND:ON")
                else
                    eventTable[k1].send(string.sub(k1,3)..":COMMAND:OFF")
                end
            end

        end

        gpio.write(ledON, gpio.HIGH)
    end
    tmr.alarm(
        debounceAlarmId,
        debounceDelay,
        tmr.ALARM_SINGLE,
        function()
            trig(config.BUTTON, "up", interuptButton)
        end
    )
end

function module.start()
    print("Configuring Wifi ...")
    -- configure LED and Button
    gpio.mode(config.LEDRedPin, gpio.OUTPUT)
    gpio.write(config.LEDRedPin, gpio.LOW)
    gpio.mode(config.LEDGreenPin, gpio.OUTPUT)
    gpio.write(config.LEDGreenPin, gpio.LOW)

    gpio.mode(config.BUTTON, gpio.INPUT)
    local fn = events.interuptButton
    gpio.trig(config.BUTTON, "up", fn)

     if config.WIFIMODE == 1 then
        modeSOFTAP()
    end
end

return module
