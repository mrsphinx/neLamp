local module = {}

module.SSID = "nodemcu"
module.PASSWORD = "12345678"
module.PORT = 1884

module.LEDRedPin = 7 -- GPIO13
module.LEDGreenPin = 5 -- GPIO14
module.BUTTON = 6 -- GPIO12

module.netClient = nil
module.state = "OFF"
module.broadcastAnswer = true

function module.loadCFG()
    if file.exists("cfg.conf") then
        local fd = file.open("cfg.conf", "r")
        if fd then
            local rd = fd:read(3)
            module.state = string.gsub(rd, "\n", "") 
            fd:close()
            fd = nil
        end
    else
        module.saveCFG(module.state)
    end
end

function module.saveCFG(val)
    if val then
        local fd = file.open("cfg.conf", "w+")
        if fd then
            module.state = val
            fd:write(val)
            fd:flush()
            fd:close()
        end
    end
end

function module.confLED(fn)
    -- configure LED and Button
    gpio.mode(module.LEDRedPin, gpio.OUTPUT)
    gpio.mode(module.LEDGreenPin, gpio.OUTPUT)
    module.clearLED()

    gpio.mode(module.BUTTON, gpio.INPUT)
    if fn and type(fn) == "function" then
        gpio.trig(module.BUTTON, "up", fn)
    end
end

function module.clearLED()
    gpio.write(module.LEDRedPin, gpio.LOW)
    gpio.write(module.LEDGreenPin, gpio.LOW)
end

function module.restore()
    if module.state == "ON" then
        gpio.write(module.LEDGreenPin, gpio.HIGH)
    elseif module.state == "OFF" then
        gpio.write(module.LEDRedPin, gpio.HIGH)
    end
end

module.blinking = {}
function module.blink(v)
    module.blinking.status = gpio.LOW
    module.blinking.count = 10
    tmr.alarm(
        3,
        500,
        1,
        function()
            if module.blinking.count == 0 then
                tmr.stop(3)
                module.clearLED()
                module.restore()
            else
                if module.blinking.status == gpio.LOW then
                    module.blinking.status = gpio.HIGH
                else
                    module.blinking.status = gpio.LOW
                end
                gpio.write(module.LEDRedPin, module.blinking.status)
                module.blinking.count = module.blinking.count - 1
            end
        end
    )
end

function module.toggleLED()
    module.clearLED()
    if module.state == "ON" then
        module.state = "OFF"
        -- module.saveCFG("ON")
        return module.LEDGreenPin
    else
        module.state = "ON"
        -- module.saveCFG("OFF")
        return module.LEDRedPin
    end
end

return module
