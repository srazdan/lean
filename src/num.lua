--vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

function num()  
  return {n=0, mu=0, m2=0, sd=0, 
          lo=10^32, hi=-10^32, all={},
          w=1}
end

function numInc(t,x,    d) 
  if x == "?" then return x end
  t.all[#t.all + 1] = x
  t.n  = t.n + 1
  d    = x - t.mu
  t.mu = t.mu + d/t.n
  t.m2 = t.m2 + d*(x - t.mu)
  if x > t.hi then t.hi = x end
  if x < t.lo then t.lo = x end
  if (t.n>=2) then 
    t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x  
end

function numDec(t,x,    d) 
  if (x == "?") then return x end
  if (t.n == 1) then return x end
  t.n  = t.n - 1
  d    = x - t.mu
  t.mu = t.mu - d/t.n
  t.m2 = t.m2 - d*(x- t.mu)
  if (t.n>=2) then
    t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x
end

function numNorm(t,x,     y) 
  return x=="?" and 0.5 or (x-t.lo) / (t.hi-t.lo + 10^-32)
end

function numXpect(i,j,   n)  
  n = i.n + j.n +0.0001
  return i.n/n * i.sd+ j.n/n * j.sd
end

