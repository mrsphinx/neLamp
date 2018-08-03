 ddd = {}
print("begin")
print(table.getn(ddd))
function c()
    print("c")
    for _, v in pairs(ddd) do
       for k,a in pairs(v) do 
        print(_,k,a)
       end
    end
end

function a(id, evt)
    print("insert")
    if ddd[evt] == nil then
        ddd[evt]={}
    end
    ddd[evt][id]=1

end
function d(id, evt)
print("delete")
    for k,a in pairs(ddd[evt]) do 
        if k== id then
            ddd[evt][k]=nil
        end
        print(k,a)
    end
 end

 function getl(T)
    local count=0
    for _ in pairs(T) do count = count +1 end
    return count
 end

a(222,"EEE")
a(33,"EEE")
a(232,"EEE")
a(221,"EEE")
a(232,"EEE")
c()
d(33,"EEE")
d(222,"EEE")
d(232,"EEE")
c()
print( getl(ddd),table.getn(ddd) )
print("end")
