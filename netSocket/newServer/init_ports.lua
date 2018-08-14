return function ()
    for k,v in pairs(s.ports) do
        gpio.mode(s.ports[k].pin,s.ports[k].mode)
        if s.ports[k].def then
            gpio.write(s.ports[k].pin,s.ports[k].def)
        end
    end
end