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
    for mac,ip in pairs(wifi.ap.getclient())do
        html = html .. "<tr>"
        html = html .. "<td>".. count .."</td>"
        html = html .. "<td>".. tostring(mac):upper() .."</td>"
        html = html .. "<td>".. ip .."</td>"
        html = html .. "</tr>"
    end
    return html
end

return module