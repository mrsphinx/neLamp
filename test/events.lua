local module={}

local events={evtPING={},
    evtON= {f=function() print("Led:ON");gpio.write(config.LEDpin,gpio.HIGH) end, enabled=1},
    evtOFF={f=function() print("Led:OFF");gpio.write(config.LEDpin, gpio.LOW) end, enabled=1},
    evtREGISTERED={f=function()
        print("I registered on the server") 
        client:send(config.ID..":SUBSCRIBE:ON")
        client:send(config.ID..":SUBSCRIBE:OFF")
    end, enabled=1}
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