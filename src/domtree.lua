
-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"

function domTree(data0,show,goal,enough,    out)
  goal   = goal or #(data0.name)
  enough = enough or (#data0.rows)^Lean.domtree.enough
  
  local function xpect(n,vals,out)
    for _,val in pairs(vals) do
      out = out + val.n.n/n * val.n.sd end
    return out 
  end

-- Score each column by the expected value of the standard
-- deviation of the `goal` values in each split.
-- As a side effect, build a table for each split (we'll need
-- that if we reurse on that split).

  local function col(data,c,       val,x,y,n,vals)
    val= function(x) return 
         {col=c, val=x, n=num(), data=header(data.name)} end
    n, vals = 0, {}
    for _,cells in pairs(data.rows) do
      x = cells[c]
      if x ~= "?" then
        y = cells[goal]
	      n = n + 1
        vals[x] = vals[x] or val(x)
        row(vals[x].data, cells)
        numInc( vals[x].n, y ) end end
    return {col= c, score= xpect(n,vals,0), vals= vals}
  end

-- If there is too little data, return a leaf node.
-- Otherwise, find the best column to split on, 
-- then recurse for each value of that split.   
-- TODO: if N siblisngs are small in part but large enoguh together
-- then report otherwise. also, add counts to parents

  local function recurse(data,kids,cols,    best) 
    for i,c in pairs(data.indeps) do 
      cols[i] = col(data,c) end
      cols = ksort("score", cols)
      best = cols[1]
      for i,val in pairs(best.vals) do
        if #(val.data.rows) < #(data.rows) then
          if #(val.data.rows) > enough then
            kids[ #kids+1 ]= {col=val.col, 
                              name=data.name[val.col],
                              val=val.val, 
                              mu=val.n.mu,
                              sub=recurse(val.data,{},{})} 
      end end end 
      return {_data=data, kids=kids}
    end

-- Print the tree

  local function display(t,     pre,pretty,s)
    pre = pre or "|.. "
    for _,kid in pairs(ksort("mu",t.kids)) do
      s= pre..kid.name.."="..kid.val
      if #kid.sub.kids == 0 then
        s= s.." --> "..math.floor(100*kid.mu) end
      print(s) 
      display(kid.sub,"|.. " .. pre) end 
  end

  out = recurse(data0,{},{})  
  if show then print(""); display(out,"") end
  return out
end

-- ## Main 
-- If called as top-level file.

return {main = function() domTree(rows(),true) end}
