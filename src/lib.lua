-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------    

require "config"
require "random"
require "rows"
require "ok"

--------- --------- --------- --------- --------- --------- 
-- ## String Stuff

function split(s, sep,    t,notsep)
  t, sep = {}, sep or ","
  notsep = "([^" ..sep.. "]+)"
  for y in string.gmatch(s, notsep) do t[#t+1] = y end
  return t
end

function fy(x)  io.stderr:write(x) end
function fyi(x) io.stderr:write(x .. "\n") end

function gsub(s,a,b,  _)
  s,_ = string.gsub(s,a,b)
  return s
end
--------- --------- --------- --------- --------- --------- 
-- ## Table Stuff
cat = table.concat
function dump(a,sep)
  for i=1,#a do print(cat(a[i],sep or ",")) end
end


function first(t)  return t[ 1] end
function second(t) return t[ 2] end
function last(t)   return t[#t] end

function splice(t,m,n,f,    u)
  f = f or function(x) return x end
  m = m or 1
  n = n or #t
  if n > #t then n=#t end
  u = {}
  for i=m,n do u[ #u+1 ]= f(t[i]) end
  return u
end

function ksort(k,t,  f) 
  f=function(x,y)
       x,y=x[k], y[k]
       if     x=="?" then return false
       elseif y=="?" then return true
      else return x < y end end
  table.sort(t,f)
  return t
end  

function shuffle( t )
  for i= 1,#t do
    local j = i + math.floor((#t - i) * rand() + 0.5)
    t[i],t[j] = t[j], t[i] end
  return t
end

function sorted(t,f)
  table.sort(t,f)
  return t
end

function member(x,t)
  for _,y in pairs(t) do if y==x then return true end end
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

function max(x,y) return x>y and x or y end
function min(x,y) return x<y and x or y end
function fmt(f,s) return string.format(f,s) end

function cols(t,     numfmt, sfmt,noline,w,txt,sep)
  w={}
  for i,_ in pairs(t[1]) do w[i] = 0 end
  for i,line in pairs(t) do
    for j,cell in pairs(line) do
      if type(cell)=="number" and numfmt then
        cell    = fmt(numfmt,cell)
        t[i][j] = cell end
      w[j] = max( w[j], #tostring(cell) ) end end
  for n,line in pairs(t) do
    txt,sep="",""
    for j,cell in pairs(line) do
      sfmt = "%" .. (w[j]+1) .. "s"
      txt = txt .. sep .. fmt(sfmt,cell)
      sep = ","
    end
    print(txt)
    if (n==1 and not noline) then
      sep="#"
      for _,w1 in pairs(w) do
        io.write(sep .. string.rep("-",w1)  )
        sep=", " end
      print("") end end
end

--------- --------- --------- --------- --------- --------- 
-- ## Num Stuff

function abs(x) return x<0 and -1*x or x end

function close(x,y,  c)
  c=c or 0.01
  return math.abs((x-y)/x) < c
end

int = function(x) return math.floor(0.5 + x) end

function cap(x, lo, hi)
  return min(hi, max(lo, x))
end
--------- --------- --------- --------- --------- --------- 
-- ## Meta Stuff

function main(t)
  if type(t) == 'table' and type(t.main) == 'function' then
       t.main(); rogues() end 
end 

function mainLib() print("lib loaded") end

return {main=mainLib}
