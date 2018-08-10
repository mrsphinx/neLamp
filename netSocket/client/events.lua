local module={}

function module.doit()
    if config.state == "ON" then
        module.toggleRelay(gpio.HIGH)
    elseif config.state == "OFF" then
        module.toggleRelay(gpio.LOW)
    end
    print("CONFIG: state:" .. config.state)
end

function module.toggleRelay(val)
    gpio.write(config.RELAY, val)
end
return module