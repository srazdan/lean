-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

do
  local seed0     = The.random.seed
  local seed      = seed0
  local modulus   = 2147483647
  local multipler = 16807
  function rseed(n) seed = n or seed0 end 
  function rand() -- park miller
    seed = (multipler * seed) % modulus
    return seed / modulus end
end

function another(x,l,     y)   
  y = math.floor(0.5+ rand() * #l)  
  if x==y then return another(x,l) end
  if l[y] then return l[y] end
  return another(x,l)
end
