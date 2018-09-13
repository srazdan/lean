-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- --------- 
require "meta"
require "num"
require "sample"

local function xtile(t,the,lo,hi,      what,where,out,b4)
  the    = complete(Lean.tiles, the)
  the.lo = lo or the.lo or t[1]
  the.hi = hi or the.hi or t[#t]
  local function fl(x)    return 1+ math.floor(x) end
  local function pos(p)   return t[ fl(p * #t) ] end
  local function place(x) 
    return fl( the.width*(x- the.lo)/
               (the.hi - the.lo+10^-32) ) end
  local function whats(chops,out)
    for _,chop in pairs(chops) do
       out[#out+1] = pos(chop[1]) end; return out
  end
  local function wheres(what,out) 
     for _,x in pairs(what) do
      out[#out+1] = place(x) end; return out
  end
  local function suffix(what,s,sep)
    for _,x in pairs(what) do
      s= s..sep..string.format(the.num,x)
      sep="," end; return s
  end
  what   = whats(the.chops,{})
  where  = wheres(what,{})
  out={}
  for i=1,(the.width + 1) do out[i] = " " end
  b4=1
  for k,now in pairs(where) do
    if k> 1 then
      for i = b4,now  do
        out[i] = the.chops[k-1][2] end  end
    b4= now  end
  out[math.floor(the.width/2)] = the.bar
  out[place(pos(0.5))]    = the.star
  return  cat(out)..","..suffix(what,'','') 
end

-- assumes everyone is sorted first
-- (all flat lists)
function xtiles(ts, the, n) 
  function med(t)    return t[int(#t/2)] end
  function sort(t,u) return med(t) < med(u) end
  n=num()
  for _,t in pairs(ts) do
    numInc(n, t[1]) 
    numInc(n, t[#t]) end 
  the = complete(the, {lo=n.lo, hi=n.hi})
  for _,t in pairs(sorted(ts, sort)) do
    print(xtile(t, the)) end
end

-- assumes everyone is sorted first
-- (all flat lists)
function xtileSamples(samples, the, n,b4,pre) 
  n=num()
  for _,s in pairs(samples) do
    numInc(n, nth(s, 0))
    numInc(n, nth(s, 1)) end
  the = complete(the, {lo=n.lo, hi=n.hi})
  for _,s in pairs(sorted(samples, sampleLt)) do
    pre = b4 ~= s.rank and "#"..s.rank or "  "
    b4  = s.rank
    print(pre..", "..
          xtile(sampleSorted(s), the).." ,"..
          s.txt) end
end
