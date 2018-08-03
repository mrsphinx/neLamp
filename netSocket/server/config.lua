local module={}

module.SSID="nodemcu"
module.PASSWORD="12345678"
module.PORT = 1884

module.LEDRedPin = 7              -- GPIO13
module.LEDGreenPin = 5            -- GPIO14
module.BUTTON = 6                -- GPIO12

module.netClient = nil
return module