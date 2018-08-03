local module={}



local ledON = config.LEDRedPin
local debounceDelay, debounceAlarmId = 200, 5


local function getl(T)
    local count=0
    for _ in pairs(T) do count = count +1 end
    return count
 end

function module.interuptButton(level, pulse1)
    gpio.trig(config.BUTTON, "none")
    local length = getl(wifi.ap.getclient())
    if length>0 then
        print("LEVEL:" .. level, "\tWHEN:" .. pulse1)
        local _SEND = "OFF"
        if ledON then
            gpio.write(ledON, gpio.LOW)
            if ledON == config.LEDGreenPin then
                ledON = config.LEDRedPin
            else
                ledON = config.LEDGreenPin
                _SEND = "ON"
            end
        else
            ledON = config.LEDGreenPin
        end
        gpio.write(ledON, gpio.HIGH)
        for mac,ip in pairs(wifi.ap.getclient()) do
            print(">>>>")
            print(ip)
            print(type(ip))
            print("<<<<")
           local conn = net.createConnection(net.TCP, 0)
           conn:on("receive", function(sck, c) print(c) end)
           conn:on("connection", function(sck) 
                print("CONNECT") 
                conn:send(_SEND)
            end)
            conn:on("reconnection", function(sck,d)  print("reconnect");print(d) end)
            conn:on("disconnection", function(sck,d)  print("disconnect");print(d) end)
            conn:on("sent",function(sck) print("sent") end)
            conn:connect(1884, "192.168.4.2")
            
        end
    end
    tmr.alarm(
        debounceAlarmId,
        debounceDelay,
        tmr.ALARM_SINGLE,
        function()
            gpio.trig(config.BUTTON, "up", module.interuptButton)
        end
    )
end

function module.STACONNECTED()
    gpio.write(config.LEDGreenPin, gpio.LOW)
    gpio.write(config.LEDRedPin, gpio.HIGH)
    ledON = config.LEDRedPin
end

return module