-- vim: filetype=lua ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "lib"

function tar3(data,cols,goal,   
              klass,x,b,r,b1,r1, rule,
              best,rest,bests,rests,rows,some,all)
  rows = data.rows
  cols = cols or data.x
  goal = goal or #data.name
  bests, rests = 0,0
  b, r, all = {}, {}, {}

  local function train(f,row,    v,old)
    for _,c in pairs(cols) do
      f[c] = f[c] or {}
  	  if c ~= goal then
        v = row.cells[c]
        if v ~= "?" then
  	      old   = f[c][v] or {
                  n=0,col=c,v=v,score=0,val={}}
          old.n = old.n + 1
          old.val[ #old.val+1 ] = row
          f[c][v] = old end end end end

  for i,row in pairs(rows) do
    klass = row.cells[goal]
    if klass:match(klass) 
      then bests= bests + 1; train(b,row)
      else rests= rests + 1; train(r,row) end end

  all = {}
  for c,vs in pairs(b) do
    for v,b3 in pairs(vs) do
      r1 = 0
      b1 = b3.n / bests
      if r[c] and r[c][v] then r1 = r[c][v].n / rests end
      if b1 > r1 then
        print(">>>",b3.col,b3.v)
        b3.score= b1^2/(b1+r1)
        all[ #all+1 ] = b3 end end end
  table.sort(all, function(a,b) return 
                    a.score > b.score end)
  some={}
  for i=1,Lean.tar3.beam do print(9); some[i] = all[i]; end
  print(1)
  for _,lst in pairs(powerset(some)) do
    print(2,#lst)
    rule = combineRanges(lst)
    o(rule) 
  end
end

return {main = function() tar3(datas()) end}
