
s = dofile("config.lua")()
-- node.setcpufreq(node.CPU160MHZ)
srvinfo = require("web_info")
net_cli_init=nil
dofile("init_ports.lua")()
dofile("init_wifi.lua")(s.wifi.wifi_mode,s.wifi.wifi_id, s.wifi.wifi_pass)