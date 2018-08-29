-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro    
--------- --------- --------- --------- --------- ---------~

require "lib"
require "distance"

function xy(data,row, left,right,c, cols,       zero1,a,b,x,y)
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
    print(#out)
    out[ #out+1 ] = {row=row,x0=0,y0=0,x=0,y=0,from=nil} end
  return out
end

function node(data,points,up,cols,        left,right)
  print(#points)
  left  = faraway(data, any(points).row, cols)
  right = faraway(data, left, cols)
  return  {points={}, cut=0, east={}, west={}, _up=up,
            c = dist(data, left, right, cols),
            left=left,
            right=right}
end

function place(data,points,here,cols,     xs,what)
  xs=0
  for _,p in pairs(points) do 
    p.x, p.y = xy(data, p.row, here.left, here.right,
                  here.c, cols)
    xs = xs + p.x
    if not p.x0 then p.x0,p.y0 = p.x,p,y end
  end
  here.cut = xs/n
  for _,point in pairs(points) do
    what = point.x > here.cut and here.east or here.west
    what[ #what+1 ] = point 
  end
end

function tree(data,points,cols, min,pre,up,     here,t)
  if not up or #up >= min then
    print(pre, #points)
    t = node(data,points,up,cols)
    place(data,points,t,cols)
    t.west = tree(t.west, t, cols,min,pre .. "|.. ", t)
    t.east = tree(t.east, t, cols,min,pre .. "|.. ", t) end
    return t
end
  
function main(data,cols)
  o(data)
  cols     = cols or indep(data)
  o(points(data.rows))
  return tree(data, points(data.rows), cols, (#data.rows)^0.5,"") 
end

return {main=function() main(rows()) end }
