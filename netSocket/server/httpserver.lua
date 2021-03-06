local module = {}

module.server = nil
local cr = {}
function module.receiver(conn, payload)
end

function module.init()
    if not module.server then
        module.server = net.createServer(net.TCP)
        if module.server then
            module.server:listen(
                80,
                function(conn)
                    local cn
                    conn:on(
                        "receive",
                        function(conn, payload)
                            local req = dofile("web_request.lua")(payload)
                            if req then
                                cn=req.uri.file
                                cr[cn] = nil
                                cr[cn] = coroutine.create(dofile("web_file.lua"))
                            end
                            if req and req.method=="GET" then 
                                print("MeTHOD:",req.method)
                                coroutine.resume(cr[cn],conn,req.uri.file,req.uri.args,req.cookie)
                            elseif req and req.method=="POST" then
                                print("METHOD:",req.method)
                                coroutine.resume(cr[cn],conn,req.uri.file,req.getReq(payload),req.cookie)
                            end
                            print(node.heap())
                        end)
                    conn:on("sent",function(conn)
                        if cr[cn] then
                            local crS=coroutine.status(cr[cn])
                            if crS=="suspended"then
                                local status = coroutine.resume(cr[cn])
                                if not status then
                                    conn:close()
                                    cr[cn]=nil
                                    collectgarbage()
                                end
                            elseif crS=="dead" then
                                conn:close()
                                cr[cn]=nill
                                collectgarbage()
                            end
                        end
                    end)
                end)
        end
    end
end

return module
