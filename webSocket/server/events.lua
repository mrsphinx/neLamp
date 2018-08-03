local module={}

module._subscribers={}

function module.switch(...)
    local id,com,val,socket = ...

    if id and com and val then
       if string.upper(com) == "REGISTER"  then
            module._subscribers[id] ={action='online'}
            if socket then
                socket.send(id..":REGISTER:REGISTERED")
            end
        elseif string.upper(com) == "SUBSCRIBE" then
            print("event subscribe")
            print(socket)
            subscribers.subscribe(id,val,socket)
            module.enterSubscribers()
        elseif string.upper(com) == "UNSUBSCRIBE" then
            subscribers.unsubscribe(id,val)
       end
    end
end

function module.enterSubscribers()
    gpio.write(config.LEDGreenPin, gpio.LOW)
    gpio.write(config.LEDRedPin, gpio.HIGH)
    ledON = config.LEDRedPin
end


local ledON = nil
local debounceDelay, debounceAlarmId, trig = 100, 5, gpio.trig


function module.interuptButton(level, pulse1)
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
            trig(config.BUTTON, "up", module.interuptButton)
        end
    )
end
return module