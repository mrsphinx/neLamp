
config = require("config")
subscribers=require("subscribers")
setup = require("setup")
events=require("events")
app = require("websocketapp")


local ok,msg = pcall(setup.start)
if ok then
    
else
    print("ERROR"..msg)
end
