-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro    
--------- --------- --------- --------- --------- ---------~

require "lib"
require "distance"

function point(t)
  return {cell=t, x=nil, y=nil}
end

function where(rows,    points)
  points={}
  for _,row in pairs(rows) do
    points[#points+1] = point(row) end
  return {min=sqrt(#rows),points=points,y=nil, c=nil}
end

function main(data)
  i = where(data.rows)
  x,y = farPairs(data.rows)

end
