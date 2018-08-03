local module = {}


local function err(x)
    print("err called", x)
    return "oh no!"
end -- err

local function modeSTATION()
    print("\nmodeStation")
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid = config.SSID, pwd = config.PASSWORD})
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        tmr.stop(1)
        print("\n====================================")
        print("ESP8266 mode is: " .. wifi.getmode())
        print("MAC address is: " .. wifi.ap.getmac())

        print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
        T.netmask.."\n\tGateway IP: "..T.gateway)
        print("====================================")
        config.setHOST(T.gateway)
        app = require("netclient")
        app.start()
    end)
    print("\nAutoconnect....")
    -- wifi.sta.autoconnect(1)
    -- tmr.alarm(1, 2500, tmr.ALARM_AUTO, wifi_wait_ip)
    return true
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
