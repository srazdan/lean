-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------    

-- ## Configuration Stuff

function defaults()
  return  {
  bore   = {goal="positive"},
  tar3   = {beam=10},
  dom    = {samples=50},
  random = {seed=10013},
  super  = {epsilon=1.01, margin=1.05,enough=0.5}, 
  ediv   = {eval="entXpect"}
  } 
end

Lean = defaults()

-- ## Unique id stuff

do 
  local id =0 
  function unique() id = id + 1; return id end
end

-- ## Maths Stuff

min = math.min
max = math.max
log = math.log
int = function (x) return math.floor(0.5+x) end

function cap(x, lo, hi) return min(hi, max(lo, x)) end

-- ## Random stuff

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

-- Table Stuff

function member(x,t,   f)
  f = f or same
  for _,y in pairs(t) do
    if f(x) == f(y) then return true end end
  return false
end

function ordered(t,  i,keys)
  i,keys = 0,{}
  for key,_ in pairs(t) do keys[#keys+1] = key end
  table.sort(keys)
  return function ()
    if i < #keys then
      i=i+1; return keys[i], t[keys[i]] end end
end

cat = table.concat
function dump(a,sep)
  for i=1,#a do print(cat(a[i].cells,sep or ",")) end
end

-- ## Set Stuff

unpack = unpack or table.unpack

function powerset(s)
  local t = {{}}
  for i = 1, #s do
    for j = 1, #t do
      t[#t+1] = {s[i], unpack(t[j])} end end
  return t
end

-- ## String Stuff

function gsub(s,a,b,  _)
  s,_ = string.gsub(s,a,b)
  return s
end

-- ## Print Stuff

function percent(x) return math.floor(100*x) end

function fy(x)  io.stderr:write(x) end
function fyi(x) io.stderr:write(x .. "\n") end

function o(t,    indent,   formatting)
  indent = indent or 0
  for k, v in ordered(t) do
    if not (type(k)=='string' and k:match("^_")) then
      formatting = string.rep("|  ", indent) .. k .. ": "
      if type(v) == "table" then
        print(formatting)
        o(v, indent+1)
      else
        print(formatting .. tostring(v)) end end end
end

-- ## File Stuff

-- Here's a simple iterator over csv files.

-- - Read rows of comma seperated data either from standard input or from a file.
-- - Kills all whitespace.
-- - Converts some strings to numbers, as appropriate.
-- - Returns the row, the row num, and a row unique id.

function csv(file,           str,cells,stream)
  stream = file and io.input(file) or io.input()
  str = io.read()
  return function ()
    while str do
      str = str:gsub("[\n\t\r ]*","")
      cells = {} 
      for word in string.gmatch(str, '([^,]+)') do 
        cells[ #cells+1 ] = tonumber(word) or word end
      str = io.read()
      return cells
    end 
    io.close(stream) end 
end

-- Meta Stuff

function same(x) return x end

function map(t,f,    t1)
  f= f or same
  t1={}
  for i,x in pairs(t) do t1[i] = f(x)  end
  return t1
end

function copy(t) return map(t,same) end

function deepCopy(t) 
  return type(t)=="table" and map(t,copy) or t end

function map2(t,u,f) -- for all x in t, call f(u,x)
  map(t, function(x) f(u,x) end) 
  return u
end

-- Goal stuff

function bore(x,g,    best,rest,n)
  g = g or Lean.bore.goal
  best,rest = 0,0
  for c,num in pairs(x.counts) do
    if c:match(g) 
      then best = best + num
      else rest = rest + num end end
  best, rest = best / x.n, rest / x.n
  return best^2 / (best + rest) 
end

function unbore(i,j, n)
  n = i.n + j.n +0.0001
  return i.n/n * (1-bore(i)) + j.n/n * (1-bore(j))
end

-- Sym Stuff

function sym()
  return {counts={},mode=nil,most=0,n=0, also={} }
end

function sinc(t,x,   new,old)
  if x=="?" then return x end
  t.also={}
  t.n = t.n + 1
  old = t.counts[x]
  new = old and old + 1 or 1
  t.counts[x] = new
  if new > t.most then
    t.most, t.mode = new, x end
  return x
end

function sdec(t,x)
  t.also={}
  if t.n > 0 then
    t.n = t.n - 1
    t.counts[x] = t.counts[x] - 1
  end
  return x
end

function entXpect(i,j,   n)  
  n = i.n + j.n +0.0001
  return i.n/n * ent(i) + j.n/n * ent(j)
end

function syms(t) return map2(t, sym(), sinc) end

function ent(t,  p)
  if not t.also.ent then
    t.also.ent=0
    for x,n in pairs(t.counts) do
      p      = n/t.n
      t.also.ent = t.also.ent - p * math.log(p,2) end end
  return t.also.ent
end

function srange(t,s )
  s=""
  for c,n in pairs(t.counts) do
    s=s.." :"..c.." "..percent(n/t.n) end
  return s
end

-- Num Stuff

function num()  
  return {n=0,mu=0,m2=0,sd=0,lo=10^32,hi=-1*10^32, w=1}
end

function ninc(t,x,    d) 
  if x == "?" then return x end
  t.n  = t.n + 1
  d    = x - t.mu
  t.mu = t.mu + d/t.n
  t.m2 = t.m2 + d*(x - t.mu)
  if x > t.hi then t.hi = x end
  if x < t.lo then t.lo = x end
  if (t.n>=2) then t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x  
end

function ndec(t,x,    d) 
  if (x == "?") then return x end
  if (t.n == 1) then return x end
  t.n  = t.n - 1
  d    = x - t.mu
  t.mu = t.mu - d/t.n
  t.m2 = t.m2 - d*(x- t.mu)
  if (t.n>=2) then t.sd = (t.m2/(t.n - 1 + 10^-32))^0.5 end
  return x
end

function norm(t,x)
  return x=="?" and 0.5 or (x-t.lo) / (t.hi-t.lo + 10^-32)
end

function nums(t) return map2(t, num(), ninc) end

function sdXpect(i,j,   n)  
  n = i.n + j.n +0.0001
  return i.n/n * i.sd+ j.n/n * j.sd
end

-- Set stuff

function intersect(old,new,  key,val,out)
  key, val, out = key or same, val or same, {}
  for _,x in pairs(old) do
    if new[ key(x) ] then
      out[ key(x) ] = val(x) end end
  return out
end

function union(t,  key,val,out)
  key, val, out = key or same, val or same, {}
  for _,x in pairs(t) do
    if not out[ key(x) ] then
      out[ key(x) ] = val(x) end end
  return out
end

-- Range stuff

function combine(t,  key,val,out,k,ks)
  key, val, out = key or same, val or same, {}
  for _,x in pairs(t) do
    ks = out[ key(x) ] or {}
    print(key(x), #ks)
    if not member( key(x), ks) then 
      ks[ #ks+1 ] = val(x)  end
    out[ key(x) ] = ks
  end
  return out
end

function combineRanges(t,   out,some,k,v)
  k   = function(z) return z.col end
  v   = function(z) return z.val end
  out = {}
  for _,vals in pairs(combine(t,k,v)) do 
    some = union(vals, k,v)
    out  = out and intersect(out,some,k,v) or some end
  return out
end

-- Data stuff

function data()
  return  {x={}, y={}, syms={}, nums={}, rows={},
           w={}, class=nil,name={}, _use={}} 
end

function header(cells,t,    c,what)
  t = t or data()
  for c0,x in pairs(cells) do
    if not x:match("%?")  then
      c = #t._use+1
      t._use[c] = c0
      t.name[c] = x
      if x:match("[<>%$]") 
	      then t.nums[c] = num()
	      else t.syms[c] = sym()
      end 
      what = t.y
      if     x:match("<") then t.w[c]  = -1 
      elseif x:match(">") then t.w[c]  =  1  
      elseif x:match("!") then t.class =  c 
      else   what = t.x end 
      what[ #what+1 ] = c
  end end
  return t
end

function rinc(t, cells)
  t.rows[ #t.rows+1 ] = {cells=cells, id=unique()} 
end

function hinc(t, cells)
  for c,num in pairs(t.nums) do ninc(num, cells[c]) end
  for c,sym in pairs(t.syms) do sinc(sym, cells[c]) end
end

function datas(file,    t)
  for cells in csv(file) do
    if t then
      rinc(t, cells)
      hinc(t, cells) 
    else
      t = header(cells,t) end end
  return t
end

function colsort(k,t,  f) 
  f=function(x,y)
       x,y=x.cells[k], y.cells[k]
       if     x=="?" then return false
       elseif y=="?" then return true
      else return x < y end end
  table.sort(t,f)
  return t
end  

-- Test stuff

function main(t)
  if type(t) == 'table' and type(t.main) == 'function' then
    t.main(); rogues() end
end

function rogues(    ignore)
  ignore = {jit=true, utf8=true, math=true, package=true, 
            table=true, coroutine=true, bit=true, os=true, 
            io=true, bit32=true, string=true, arg=true, 
            debug=true, _VERSION=true, _G=true }
  for k,v in pairs( _G ) do
   if type(v) ~= "function" and not ignore[k] then
    if k:match("^[^A-Z]") then
     print("-- warning, rogue local ["..k.."]") end end end 
end 

do
  local tries, fails = 0,0

  function okReport( x)
    x = (tries-fails)/ (tries+10^-64)
    return math.floor(0.5 + 100*(1- x)) end

  function ok(t,  n,score,      passed,err,s)
    for x,f in pairs(t) do
      tries = tries + 1
      print("-- Test #" .. tries .. 
            " (oops=".. okReport() .."%). Checking ".. x .."... ")
      Lean = defaults()
      passed,err = pcall(f)
      if not passed then
        fails = fails + 1
        print("-- E> Failure " .. fails .. " of " 
              .. tries ..": ".. err) end end
    rogues()
  end
end

function off(t) return t end
