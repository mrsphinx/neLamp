local module={}

function module.getIP()
    local ip, nm, gw = wifi.ap.getip()
    return ip
end

function module.getNM()
    local ip, nm, gw = wifi.ap.getip()
    return nm
end

function module.getGW()
    local ip, nm, gw = wifi.ap.getip()
    return gw
end

function module.getStationList()
    local html = ""
    local count=1;
    if net_cli_init then
        for mac,v in pairs(net_cli_init.mac)do
            html = html .. "<tr>"
            html = html .. "<td>".. count .."</td>"
            html = html .. "<td>".. tostring(mac):upper() .."</td>"
            html = html .. "<td>".. v.ip .."</td>"
            html = html .. "<td>".. v.state .."</td>"
            html = html .. "</tr>"
            count=count+1
        end
    end
    return html
end

return module