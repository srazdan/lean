-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "lib"
require "stats"
require "sample"
require "ok"


ok { stats = function(    t,u,r,inc,n)
  r,inc = 512,.025
  rseed(1)
  for d=1,1.5,inc do
    t = sample()
    u = sample()
    for i=1,r do 
      n = rand() 
      sampleInc(t, n) 
      sampleInc(u, n*d) end 
    t = sampleSorted(t)
    u = sampleSorted(u)
    print(d, different(t,u))
end  end }

