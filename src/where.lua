-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro    
--------- --------- --------- --------- --------- ---------~

require "lib"
require "distance"

function point(t) return {row=t, x=nil, y=nil} end

function points(rows, u)
  u={}
  for _,row in pairs(rows) do u[#u+1] = point(row) end
  return u
end

function xy(t,west,east,p,use,       trim,a,b)
  trim = function(x) return min(1,max(0, x)) end
  if not p.x then
    a   = dist(t,p.row, w.east, use)
    b   = dist(t,p.row, w.west, use)
    p.x = (a^2 + c^2 - b^2)/(2*c)
    p.y = trim(a^2 - p.x^2)^0.5 end
  return p.x, p.y
end

function main(data,use)
  use = use or indep(data)
  east, west = farPairs(data.rows)
  w = where(data.rows,west,east)
  w.c = dist(data,t.x,t.y,use)
  for _,p in w.points do  p.x, p.y = xy(t,p,use) end
  return tree(points(data.rows), sqrt(#data.rows))
end

function tree(w)

