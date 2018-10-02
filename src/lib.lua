-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------    

-- ## Configuration Stuff

function Lean0(     f,t) 
  if _G["Lean"] then
    t,f= Lean.ok.tries, Lean.ok.fails end
  return  {
  ok       = {tries= t or 0, fails=f or 0},
  super    = {epsilon=1.01, margin=1.05} 
  } end

Lean = Lean0()

-- ## Unique id stuf

do 
  local id =0 
  function unique() id = id + 1; return id end
end

-- ## Maths Stuff

log = math.log

-- Table Stuff

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
  for i=1,#a do print(cat(a[i],sep or ",")) end
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

function csv(file,           n,str,row,stream)
  stream = file and io.input(file) or io.input()
  n,str  = 0, io.read()
  return function ()
    while str do
      str = str:gsub("[\n\t\r ]*","")
      n   = n + 1
      row = {} 
      for word in string.gmatch(str, '([^,]+)') do 
        row[ #row+1 ] = tonumber(word) or word end
      str   = io.read()
      return {cells=row, n=n, id=unique()} 
    end 
    io.close(stream) end 
end

-- Data stuff

function data()
  return  {x={}, y={}, syms={}, nums={}, rows={},
           class=nil,name={}, _use={}} end

function header(cells,t,    c,what)
  t = t or data()
  for c0,x in pairs(cells) do
    if not x:match("%?")  then
      c = #t._use+1
      t._use[c] = c0
      t.name[c] = x
      if x:match("[<>%$]") 
	      then t.nums[c] = true 
	      else t.syms[c] = true
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

function datas(file,    t)
  for row in csv(file) do
    if row.n == 1 
      then t = header(row.cells,t)
      else t.rows[ #t.rows+1 ] = row end end 
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

function nums(t) return map2(t,num(), ninc) end

function numXpect(i,j,   n)  
  n = i.n + j.n +0.0001
  return i.n/n * i.sd+ j.n/n * j.sd
end
