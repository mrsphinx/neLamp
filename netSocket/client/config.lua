local module={}

module.SSID="nodemcu"
module.PASSWORD="12345678"
module.RELAY = 2                  -- declare LED pin
module.PORT = 1884


module.state = "OFF"

function module.loadCFG()
    if file.exists("cfg.conf") then
        local fd = file.open("cfg.conf", "r")
        if fd then
            module.state = fd:readline()
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
            fd:writeline(val)
            fd:flush()
            fd:close()
        end
    end
end


return module