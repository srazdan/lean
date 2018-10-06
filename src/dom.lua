-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------   

require "lib"

function dom(t,row1,row2,     n,a0,a,b0,b,s1,s2)
  s1,s2,n = 0,0, 0
  for _ in pairs(t.w) do n=n+1 end
  for c,w in pairs(t.w) do
    a0  = row1.cells[c]
    b0  = row2.cells[c]
    a   = norm( t.nums[c], a0)
    b   = norm( t.nums[c], b0)
    s1 = s1 - 10^(w * (a-b)/n)
    s2 = s2 - 10^(w * (b-a)/n)
  end
  return s1/n < s2/n 
end

function doms(t,  n,c,row1,row2,s)
  n= Lean.dom.samples
  c= #t.name + 1
  print(cat(t.name,",") .. ",>dom")
  for r1=1,#t.rows do
    row1 = t.rows[r1]
    row1.cells[c] = 0
    for s=1,n do
     row2 = another(r1,t.rows) 
     s = dom(t,row1,row2) and 1/n or 0
     row1.cells[c] = row1.cells[c] + s end end
  dump(t.rows)
end

return {main = function() doms(datas()) end }
