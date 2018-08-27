-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "config"
require "rows"
require "num"
require "random"

--------- --------- --------- --------- --------- --------- 
-- ## String Stuff

function split(s, sep,    t,notsep)
  t, sep = {}, sep or ","
  notsep = "([^" ..sep.. "]+)"
  for y in string.gmatch(s, notsep) do t[#t+1] = y end
  return t
end

cat = table.concat
function dump(a,sep) 
  for i=1,#a do print(cat(a[i],sep or ",")) end
end

function fyi(x) io.stderr:write(x .. "\n") end

--------- --------- --------- --------- --------- --------- 
-- ## Table Stuff

function ksort(k,t) 
  table.sort(t,function(x,y) return 
            x[k] ~= "?" and y[k] ~="?" and x[k] < y[k] end) 
  return t
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
    formatting = string.rep("|  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      o(v, indent+1)
    else
      print(formatting .. v) end end 
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
-- ## Meta Stuff

function main(t)
  if type(t) == 'table' and type(t.main) == 'function' then
       t.main() end 
end 

function mainLib() print("lib loaded") end

return {main=mainLib}
