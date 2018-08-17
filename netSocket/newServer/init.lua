adc.force_init_mode(adc.INIT_ADC)
local index = 0
local buf={}
for i=1,14 do
 buf[i]=0
end
buf[14]=1

spi.setup(0,spi.MASTER,spi.CPOL_LOW,spi.CPHA_LOW,16,80)

spi.send(0, 0, buf)

tmr.alarm(1,1000,tmr.ALARM_AUTO,function()
    local key = adc.read(0)
    if key < 20 then
        print(key)
        buf[1]=index
        index = index+1
        spi.send(0, 0, buf)
    end
end)

-- s = dofile("config.lua")()
-- -- node.setcpufreq(node.CPU160MHZ)
-- srvinfo = require("web_info")
-- net_cli_init=nil
-- dofile("init_ports.lua")()
-- dofile("init_wifi.lua")(s.wifi.wifi_mode,s.wifi.wifi_id, s.wifi.wifi_pass)
