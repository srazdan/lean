-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro    
--------- --------- --------- --------- --------- ---------~

require "lib"
require "distance"

function xy(data,row, left,right,c,cols,       zero1,a,b,x,y)
  zero1 = function(x) return min(1,max(0, x)) end
  a = dist(data, row, right, cols)
  b = dist(data, row, left, cols)
  x = zero1((a^2 + c^2 - b^2)/(2*c))
  y = zero1(a^2 - x^2)^0.5
  return x, y
end

function points(rows, out)
  out = {}
  for _,row in pairs(rows) do 
    out[ #out+1 ] = {row=rows,x=0,y=0,from=nil} end
  return out
end
 
function node(data,up,cols,     out,xs,n,what,left,right,c)
  left  = faraway(data, any(up).row, cols)
  right = faraway(data, left, cols)
  c     = dist(data, left, right, cols)
  out = {_up=up, left=left, right=right, points={}, 
          c=c,   xmid=0,    east={}, west={}}
  for _,p in pairs(up) do 
    x,y = xy(data,p.row, left,right,c,cols)
    xs = xs + x
    out.points[#out.points+1] = {row=row, x=x, y=y, _cluster=out} end
  out.xmid = xs/n
  for _,p in pairs(out.points) do
    what = p.x > out.xmid and out.east or out.west
    what[ #what+1 ] = p end
  return out
end

function main(data,cols)
  cols = cols or indep(data)
  pnts = points(data.rows)
  data.top = node(data, points(data.rows), cols)
  return tree(data, data.top, sqrt(#data.rows))
end

function tree(data, up, cols,min)
  if #up.points < min then return nil end


