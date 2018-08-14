local module = {}

module.mac={}

local function getl(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function module.updateMAC(mac,ip)
    module.mac[mac]={IP=ip,state=false}
end

function module.interruptButton(level, pulse1)
    gpio.trig(s.ports.keyboard.pin, "none")
        s.net.state = not s.net.state
        module.srvUdp:send(s,net.net_port,module.bip,"CMD:"..s.net.state)
    tmr.alarm(
        5,
        500,
        tmr.ALARM_SINGLE,
        function()
            gpio.trig(s.ports.keyboard.pin, "up", module.interruptButton)
        end
    )
end

function module.init()
    module.srvUdp = net.createUDPSocket()
    module.bip = wifi.ap.getbroadcast()
    module.srvUdp.on(
        "receive",
        function(s, data, port, ip)
            local cmd, answ, mac = string.match(data, "^(.+)-(.+)-(.+)$")
            if cmd=="CMD" or cmd=="echo"then
                module.mac[mac].IP = ip
                module.mac[mac].state=answ
            end
            print(string.format("received '%s' from %s:%d", data, ip, port))
        end
    )
    tmr.alarm(4,10000,tmr.ALARM_AUTO,function()
        module.srvUdp:send(s.net.net_port,module.bip,"echo")
    end)
    gpio.trig(s.ports.keyboard.pin, "up", module.interruptButton)
end


return module
