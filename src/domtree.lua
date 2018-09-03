
-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "nums"

function domTree(data0,goal,enough)
  goal   = goal or #(data0.rows[1])
  enough = enough or (#data0.rows)^Lean.domTree.enough
  
  local function colOrder(x,y)   return x.xpect < y.xpect end

  local function val(c,x)
    return {col=c, val=x, data=header(data0.name), n=num()} end

  local function xpect(n,vals,out)
    for _,val in pairs(vals) do
      out = out + val.n.n/n * val.n.sd end
    return out 
  end

  local function col(data,c,     x,y,n,xpect,vals,holds)
    n, vals = 0, {}
    for _,cells in pairs(data.rows) do
      x = cells[c]
      if x ~= "?" then
        y = cells[goal]
	      n = n + 1
        vals[x] = vals[x] or val(c,x)
        row(vals[x].data, cells)
        numInc( vals[x].n, y ) end end
    return {col= c, xpect= xpect(n,vals,0), vals= vals}
  end

-- need to get the cut value in there

  local function recurse(data,kids,cols) 
    if #data.rows < enough then 
      return {data=data, kids={}}
    else
      for i,c in pairs(data.indeps) do 
        cols[i] = col(data,c) end
      cols = sorted(cols, colOrder)
      for _,val in pairs(cols[1].vals) do
        kids[val.c]= recurse(val.data,{},{}) end end
      return {data=data, kids=kids}
    end

  recurse(data0,{},{})
end

-- ## Main 
-- If called as top-level file.

return {main = function() domTree(rows()) end}
