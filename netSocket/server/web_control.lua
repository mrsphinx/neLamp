return function(tab)
    print("TABS",tab.init)
    print(rconcat(tab))
    local r=""
    for k,v in pairs(tab) do
        print(k,":",v)
        r = r .. k
        r = r .. ":"
        r = r .. v
    end
    return r
end


