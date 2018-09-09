-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

function same(x) return x end

function map(t,f,    out)
  out = {}
  if t ~= nil then
    for i,v in pairs(t) do out[i] = f(v) end end
  return out
end

function copy(t) return map(t,same) end

function deepCopy(t)
  return type(t)=="table" and map(t,deepCopy) or t
end

function complete(t1,t2,    out)
  out = deepCopy(t1 or {})
  for x,y in pairs(t2 or {}) do out[x] = y end 
  return out
end


