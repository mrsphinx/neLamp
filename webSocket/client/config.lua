local module={}

module.SSID="nodemcu"
module.PASSWORD="12345678"
module.WIFIMODE = 0               -- 0 - STATION, 1 - ACCESS POINT
module.LEDpin = 2                  -- declare LED pin

module.HOST = "192.168.4.2"
module.PORT = 1884
module.ID = node.chipid()

function module.setHOST(newHost)
    module.HOST= newHost
end

module.ENDPOINT = "nodemcu/"
return module