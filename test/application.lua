local module={}
m=nil

local function send_ping()
    print("ping-pong")
    m:publish(config.ENDPOINT .. "ping","id="..config.ID,0,0)
end
local function register_myself()
    print("REGISTER")
    m:subscribe(config.ENDPOINT..config.ID,0,function(conn)
        print("Successfully subscribeed to data endpoint")
    end)
end

local function handle_mqtt_error(client,reason)
    print("REASON:"..reason)
end

local function mqtt_start()
    print("create mqtt_client")
    m = mqtt.Client(config.ID, 120)
    print("on message")
    m:on("message",function(conn, topic, data)
        if data ~= nil then
            print( topic.. ":".. data)
        end
    end)
    print("on connect")
    m:connect(config.HOST, config.PORT, 0,  function(conn)
        print("mconnect")
        register_myself()
        tmr.stop(6)
        
        tmr.alarm(6,10000,1,send_ping)
    end,handle_mqtt_error)

end

function module.start()
    print("mqtt_start")
    mqtt_start()
end
return module