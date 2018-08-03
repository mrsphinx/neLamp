
local module={}

module.SSID="nodemcu"
module.PASSWORD="12345678"
module.WIFIMODE = 1               -- 0 - STATION, 1 - ACCESS POINT

module.HOST = "192.168.4.2"
module.PORT = 1884
module.ID = node.chipid()

module.LEDRedPin = 7              -- GPIO13
module.LEDGreenPin = 5            -- GPIO14
module.BUTTON = 6                -- GPIO12

module.ENDPOINT = "nodemcu/"
return module