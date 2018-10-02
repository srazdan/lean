-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------    

-- ## Configuration Stuff

function Lean0(     f,t) 
  if _G["Lean"] then
    t,f= Lean.ok.tries, Lean.ok.fails end
  return  {
  ok       = {tries= t or 0, fails=f or 0}
  } end

Lean = Lean0()

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

function csv(file,           n,str,row,stream)
  stream = file and io.input(file) or io.input()
  n,str  = 0, io.read()
  return function ()
    while str do
      n   = n + 1
      row = {} 
      str = str:gsub("[\n\t\r ]*","")
      for word in string.gmatch(str, '([^,]+)') do 
        row[ #row+1 ] = tonumber(word) or word end
      str   = io.read()
      return row, n, #row 
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
