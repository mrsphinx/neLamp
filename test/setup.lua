local module={}

local function wifi_wait_ip()
    if wifi.sta.getip()== nil then
      print("IP unavailable, Waiting...")
    else
      tmr.stop(1)
      print("\n====================================")
      print("ESP8266 mode is: " .. wifi.getmode())
      print("MAC address is: " .. wifi.ap.getmac())
      print("IP is "..wifi.sta.getip())
      print("====================================")
      app = require("application")
      app.start()
    end
  end
  
  local function wifi_start(list_aps)
      if list_aps then
          for key,value in pairs(list_aps) do
              if config.SSID and config.SSID[key] then
                  wifi.setmode(wifi.STATION);
                --   wifi.sta.config(key,config.SSID[key])
                  wifi.sta.connect()
                  print("Connecting to " .. key .. " ...")
                  --config.SSID = nil  -- can save memory
                  tmr.alarm(1, 2500, 1, wifi_wait_ip)
              end
          end
      else
          print("Error getting AP list")
      end
  end
  
  function module.start()
    print("Configuring Wifi ...")
    if config.WIFIMODE == 0 then
        wifi.setmode(wifi.STATION);
        wifi.sta.getap(wifi_start)
    end
    if config.WIFIMODE == 1 then 
        wifi.setmode(wifi.SOFTAP);
        wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
            print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
            local ip, nm, gw = wifi.ap.getip()
            print("\n\tIP:"..ip.."\tmask:"..nm.."\tGW:"..gw)
            local table={}
            table=wifi.ap.getclient()
            for mac,ip in pairs(table) do
                print(mac,ip)
            end
            app = require("netclient")
            app.start()
            end)
        wifi.ap.config({ssid=config.SSID,pwd=config.PASSWORD})
       
    end
  end
  
  return module