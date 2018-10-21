-- vim: filetype=lua ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"

function some(f,want,  n)
  n,want = 0,want or 10^32
  return function()
    n = n + 1
    return n <= want and f(),n or nil end
end

function uniform(lo,hi)
  return function()
    return lo + rand()*(hi - lo) end
end

function sample(t,       i)
  return function( i)
    i = cap(math.floor(0.5+rand()*#t),1,#t-1) 
    return t[i] + rand()*(t[i+1] - t[i]) end
end

function triangular(lo,mode,hi,    c)
  c = (mode-lo)/(hi-lo)
  return function(   u,v,x)
     u,v = rand(),rand()
     x = (1-c)*min(u,v) + c*max(u,v)
     return lo + x*(hi-lo) end
end

function gaussian(mu,sd)
  local function polar( x,y)
    x = -1+2*rand()
    y = -1+2*rand()
    return x,x*x + y*y end
  return function(   r,x)
    r=0
    while (r >= 1) or (r == 0) do x,r=polar() end
    return mu + sd*x*(-2 * log(r) / r)^0.5 end
end

function bars(t,      default,all,total)
  total, all = 0, {}
  for k,v in pairs(t) do 
    total = total + v
    all[#all+1] = {k,v} end
  table.sort(all, function(x,y) return x[2] > y[2] end)
  default=all[#all][1]
  return function (  r,k,v)
    r = rand()
    for _,pair in pairs(all) do
      k,v = pair[1], pair[2]
      r   = r - v/total
      if r <= 0 then return k end end
    return default end
end

function rall(t) return {what="all",  items=t} end
function rany(t) return {what="any",  items=t} end
function rone(t) return {what="one", items=t} end

function features(t,root,     wme,n) 
  local function feature1(token,wme,pre,    hi,x)
    x = t.rules[token]
    if x then
      x.items = shuffle(x.items)
      n = #x.items
      if   x.what == "all" 
      then hi = n
      else hi = cap(math.floor(0.5+rand()*n),1,n) 
      end
      for i =1, hi do
        feature1(x.items[i],  wme, pre .. "|.. ") 
        if x.what == "one" then break end end 
    else
      wme[ token ] = true
    end
    return wme
  end

  local function implied()
    for _,two in pairs(t.implies) do
      if wme[two[1]] and not wme[two[2]] 
        then return false end end
    return true
  end

  local function excluded(  n)
    for _,es in pairs(t.excludes) do
      n = 0
      for _,e in pairs(es) do 
        if wme[e] then n = n + 1 end end
      if  n==1 then return true end end
    return false
  end

  wme = feature1(root,{},"")
  if implied(wme) and not excluded(wme) then return wme end
end
