local module={}

local events={evtPING={},
    evtON= {f=function(sck) print("Led:ON");gpio.write(config.LEDpin,gpio.HIGH) end, enabled=1,name="ON"},
    evtOFF={f=function(sck) print("Led:OFF");gpio.write(config.LEDpin, gpio.LOW) end, enabled=1,name="OFF"},
    evtREGISTERED={f=function(sck)
        print("I registered on the server");
        tmr.alarm(2,200,tmr.ALARM_SINGLE, function()
            sck:send(config.ID..":SUBSCRIBE:ON");
        end)
        -- sck:send(config.ID..":SUBSCRIBE:ON");
        tmr.alarm(3,400,tmr.ALARM_SINGLE, function()
            sck:send(config.ID..":SUBSCRIBE:OFF");
        end)
    end, enabled=1,name="REGISTER"}
}

function module.setEvents(evt,val)
    -- if events["evt"..evt] then
        events["evt"..evt] = val
    -- end
end

function module.getEvents(evt)
    if events["evt"..evt] then
        return events["evt"..evt]
    end
    return nil
end

return module