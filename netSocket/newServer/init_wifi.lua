return function(m, i, p)
    local cfg = {}
    cfg.ssid = i
    cfg.pwd = p
    if m == "SOFTAP" then
        print("Access point...")
        wifi.setmode(wifi.SOFTAP)
        wifi.ap.config(cfg)
        wifi.eventmon.register(
            wifi.eventmon.AP_STACONNECTED,
            function(T)
                print("\n\tAP -> STATION CONNECTED" .. "\n\tMAC: " .. T.MAC .. "\n\tAID: " .. T.AID)
                local ip, nm, gw = wifi.ap.getip()
                print("\n\tIP:" .. ip .. "\tmask:" .. nm .. "\tGW:" .. gw)
                if not web_srv_init then
                    dofile("web.lua")
                end
                if not net_cli_init then
                    net_cli_init =  dofile("net.lua")
                    net_cli_init.init()
                end
                net_cli_init.updateMAC(T.MAC,ip)
            end
        )
    end
end
