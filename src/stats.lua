-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"

function cliffsDelta(lst1,lst2,    threshold,
                     lt,gt,max,pos0,pos,out)
  threshold = threshold or Lean.stats.cf
  local function bsearch(t,val,  lo,hi)
    lo,hi=1,#t
    while lo <= hi do
      local mid = (lo+hi)/2
      mid = math.floor(mid)
      if t[mid] >= val then
        hi = mid - 1
      else
        lo = mid + 1 end end
    return math.min(lo,#t)
  end
  
  lt,gt,max=0,0,#lst2
  for _,one in pairs(lst1) do
    pos0 = bsearch(lst2,one)
    pos = pos0
    while pos < max and lst2[pos] == lst2[pos+1] do pos = pos + 1 end
    gt = gt + max - pos
    pos = pos0
    while pos > 1   and lst2[pos] == lst2[pos-1] do pos = pos - 1 end
    lt = lt + pos end
  out= math.abs(gt - lt) / (#lst1 * #lst2) 
  --print(); o{thres=threshold, gt=gt, lt=lt, out=out}
  return out > threshold
end

function bootstrap(y0,z0,  
                   n,x,y,z,tobs,yhat,zhat,bigger,b,conf)
  b    = Lean.stats.bootstraps
  conf = Lean.stats.conf/100
  local function sampleWithReplacement(lst)
    local function n()   return math.floor(rand() * #lst) + 1 end
    local function one() return lst[n()] end
    local out={}
     for i=1,#lst do out[i] = one() end
     return out
  end
  local function delta(y,z)
    return (y.mu - z.mu) / (10^-64 + (y.sd/y.n + z.sd/z.n)^0.5)
  end
  x, y, z = num(1024), num(1024), num(1024)
  for _,m in pairs(y0) do numInc(x,m); numInc(y,m) end
  for _,m in pairs(z0) do numInc(x,m); numInc(z,m) end
  tobs = delta(y,z)
  yhat, zhat = {}, {}
  for _,m in pairs(y._some.some) do 
    yhat[#yhat+1] = m  - y.mu + x.mu end
  for _,m in pairs(z._some.some) do 
    zhat[#zhat+1] = m  - z.mu + x.mu end
  bigger = 0
  for _ = 1,b do
    if delta(nums(sampleWithReplacement(yhat)),
             nums(sampleWithReplacement(zhat))) > tobs then
      bigger = bigger + 1 end end
  return bigger / b > conf 
end

function different(lst1,lst2)
  return cliffsDelta(lst1,lst2) and bootstrap(lst1,lst2)
end
