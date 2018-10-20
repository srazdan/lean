-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"

-- Based on Aha et al. [Instance-based Learning Algorithms](https://link.springer.com/content/pdf/10.1007/BF00153759.pdf) -- (see top of p42).

function dist(t,row1,row2,cols,  p,   d,n,x,y,f,d1,n1)
  cols = cols or t.indeps
  p    = p    or Lean.distance.p
  function symDist(x,y)
    if     x=="?" and y=="?" then return 1 
    elseif x=="?" or  y=="?" then return 1 
    elseif x==y              then return 0
    else                          return 1
    end
  end
  
  function numDist(t,x,y)
    if x=="?" and y=="?" then 
      return 0,0 
    elseif x=="?" then 
      y = numNorm(t,y) 
      x = y < 0.5 and 1 or 0
    elseif y=="?" then
      x = numNorm(t,x) 
      y = x < 0.5 and 1 or 0
    else 
      x,y = numNorm(t,x), numNorm(t,y) 
    end
    return (x-y)^p
  end

  d,n = 0,0
  for _,c in pairs(cols) do
    x, y  = row1[c], row2[c]
    if t.nums[c] 
      then d1 = numDist(t.nums[c],x,y) 
      else d1 = symDist(x,y)
    end
    d, n = d + d1, n + 1 
  end
  return (d/n) ^ (1/p) 
end

function around(data,row1,rows,cols,  tmp,row2,d)
  rows   = rows or data.rows
  cols   = cols or data.indeps
  tmp    = {}
  for i=1,Lean.distance.samples do
    row2 = any(rows)
    d    = dist(data,row1,row2,cols)
    if d > 0 then tmp[#tmp+1]= {row2, d} end
  end
  table.sort(tmp, function(a,b) return second(a) < second(b) end)
  return tmp
end

function faraway(data,row1,rows) 
  return first( around(data,row1,rows)[95] ) 
end
