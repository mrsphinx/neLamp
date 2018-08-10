local module = {}


function module.init()
    gpio.mode(config.RELAY, gpio.OUTPUT)
    events.doit()
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid = config.SSID, pwd = config.PASSWORD})
    wifi.eventmon.register(
        wifi.eventmon.STA_GOT_IP,
        function(T)
            print(
                "\n\tSTA - GOT IP" ..
                    "\n\tStation IP: " .. T.IP .. "\n\tSubnet mask: " .. T.netmask .. "\n\tGateway IP: " .. T.gateway
            )
           
            -- module.initTcpServer()
            module.initUdpServer()
        end
    )
    return true
end

function module.initUdpServer()
    module.udpServer = net.createUDPSocket()
    module.udpServer:listen(config.PORT)
    module.udpServer:on("receive",module.onUdpRecv)
end

function module.onUdpRecv(s,data, port, ip)
    print(string.format("received '%s' from %s:%d", data, ip, port))
    print(data)
    print("LEN:"..string.len(data))
    print("Byte:"..string.byte(data,1,string.len(data)))
    if data== "ON" or  data=="OFF" then
        print("SAVE CONF:"..data)
        config.saveCFG(data)

        events.doit()
        s:send(port,ip,data.."-"..wifi.sta.getmac())
    end
end

function module.initTcpServer()
    module.tcpServer = net.createServer(net.TCP)
    module.tcpServer:listen(config.PORT, function(conn) 
        conn:on("receive", module.onTcpRecv) 
    end)
    
    
    print("TCP Server started on port " .. config.PORT)
end

function module.onTcpRecv(sck, data)
    local peer = sck:getpeer()
    print("TCP Recvd. data: " .. data .. ", Peer:" .. peer)
end

return module
