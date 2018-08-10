function rconcat(T)
    if type(T) ~= "table" then return T end
    local res ={}
    for i=1,#T do
        res[i]=rconcat(T[i])
    end
    return table.concat(res)
end


config = require("config")
config.loadCFG()
srvinfo = require("server_info")
events= require("events")
httpserver=require("httpserver")
setup = require("setup")
setup.start()