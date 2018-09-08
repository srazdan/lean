-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

require "config"

do
  local seed0     = Lean.random.seed
  local seed      = seed0
  local modulus   = 2147483647
  local multipler = 16807
  function rseed(n) seed = n or seed0 end 
  function rand() -- park miller
    seed = (multipler * seed) % modulus
    return seed / modulus end
end

function another(x,t,     y)   
  y = cap(math.floor(0.5+rand()*#t),1,#t)
  if x==y then return another(x,t) end
  if t[y] then return t[y] end
  return another(x,t)
end

function any(t,    x)
  return t[ cap(math.floor(0.5+rand()*#t),1,#t) ]
end
