require "lib"
require "rows"

v=function(x) return fmt("%4.2f",x) end

d = rows()
for c,n in pairs(d.nums) do
  print(c, d.name[c], n.n, v(n.mu), v(n.sd))  end
for c,s in pairs(d.syms) do
  print(c, d.name[c], s.n,s.mode, s.most) end
