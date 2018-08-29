-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "rows"

function symDist(t,x,y)
  if x=="?" and y=="?" then return 0,0 end
  if x=="?" or  y=="?" then return 1,1 end
  return x==y and 0,1 or 1,1
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
  return (x-y)^2, 1
end

function indeps(t, u)
  u = {}
  for _,c in pairs(t.names) do 
    if indep(c) then u[#u+1]=c end end
  return u
end

function dist(t,row1,row2,cols,    d,n,x,y,f,d1,n1)
  d,n = 0,0
  for _,c in pairs(cols) do
    x, y  = row1[c], row2[c]
    f     = nump[c] and numDist or symDist
    d1,n1 = f(t,x,y) 
    d, n  = d + d1, n + n1 end
  return d^(1/2) / n^(1/2)
end

function faraway(t,row1,rows,cols,  tmp,row2)
  tmp = {}
  rows = rows or t.rows
  cols = cols or indeps()
  for i=1,100 do
    row2 = any(rows)
    tmp[ #tmp+1 ] = {row2, dist(t, row1, row2, cols, The.num.p)}
  end
  table.sort(tmp, function(a,b) return a[2] < a[2] end)
  return tmp[95][1]
end
