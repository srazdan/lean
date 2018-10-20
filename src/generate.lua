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

Rand,Rany,Ror,Requires,Excludes=1,2,3,4,5

function random0(t,n) 
  table.sort(t,function(a,b) return rand() < 0.5 end)
  return {want=n, items=t}
end

function rall(t) return {what="all", items=t} end
function rone(t) return {what="some", items=t} end

a= {rules= {phone  = rall{"calls",  "gps","screen","camera"},
            screen = rone{"basic", "color","highres"},
	    media  = rone{"camera", "mps"}}, 
    nogood={{Requires, {"camera"},
                      {"highres"}},
           {Excludes, {"basic"}, 
                      {"gps"}}}}

function features1(token, rules, wme,pre)
  pre, wme = pre or "|.. ", wme or {}
  x=rules[token]
  print(pre,totnmx)
  if x then
	  print(x.items)
    table.sort(x.items, function(a,b) return rand() < 0.5 end)
    hi= x.what=="some" and rand()*#x or #x
    for sub =1, hi do
      features1(x.items[i], rules, wme, pre .. "|.. ") end 
  else
    wme[ #wme+1 ] = token
  end
  return wme
end

function features(t) 
  for i=1,20 do print(features1("phone",a.rules)) end 
end

features(a.rules)
