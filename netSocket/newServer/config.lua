local function write_to_file(s, f)
    local ok, json = pcall(sjson.encode, s)
    if ok then
        if file.open(f, "w") then
            file.write(json)
            file.close()
        end
        print(json)
        return "true"
    else
        return "false"
    end
end

local function def(v)
    local s
    if file.open("settings.json", "r") then
        local ok, j = pcall(sjson.decode, file.read("\n"))
        s = ok and j or {}
        s.token = crypto.toBase64(node.random(100000))
        file.close()
    else
        s = {
            wifi = {
                wifi_id = "nodemcu",
                wifi_pass = "12345678",
                wifi_mode = "SOFTAP"
            },
            net = {net_port = 1884,state=false},
            ports = {
                -- led_red_pin = {pin = 7, mode = gpio.OUTPUT, def = gpio.LOW, action = 0}, -- GPIO13
                -- led_green_pin = {pin = 5, mode = gpio.OUTPUT, def = gpio.LOW, action = 1}, -- GPIO14
                -- keyboard = {pin = 6, mode = gpio.INPUT} -- GPIO12
            }
        }
        write_to_file(s, "settings.json")
        s.token = crypto.toBase64(node.random(100000))
    end
    return s
end

return function(t)
    local r = def(t)
    return r
end
