local module = {}

local debounceDelay, debounceAlarmId = 200, 5

local function getl(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function module.interuptButton(level, pulse1)
    gpio.trig(config.BUTTON, "none")
    local length = getl(wifi.ap.getclient())
    if length > 0 then
        config.broadcastAnswer = true
        setup.count=10
        for k,v in pairs(setup.mac) do
            setup.mac[k]=0
        end
        setup.sendCustomBroadcast(
            config.state,
            function()
                config.clearLED()
                if config.state == "ON" then
                    gpio.write(config.LEDGreenPin, gpio.HIGH)
                    config.state="OFF"
                else
                    gpio.write(config.LEDRedPin, gpio.HIGH)
                    config.state="ON"
                end
            end
        )
        print("LEVEL:" .. level, "\tWHEN:" .. pulse1)
    -- tmr.alarm(
    --     4,
    --     100,
    --     tmr.ALARM_SINGLE,
    --     function()
    --         if config.broadcastAnswer == false then
    --            config.blink()
    --         else
    --             local _ledPin = config.toggleLED()
    --             gpio.write(_ledPin, gpio.HIGH)
    --         end
    --     end
    -- )
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

return module
