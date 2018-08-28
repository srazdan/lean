
-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path 
require "lib"
require "ok"
require "num"

ok {numOkay = function(    n,t)
  n = nums{ 4,10,15,38,54,57,62,83,100,100,174,190,215,225,
       233,250,260,270,299,300,306,333,350,375,443,475,
       525,583,780,1000}
  assert(close(n.mu, 270.3  ))
  assert(close(n.sd, 231.946))
  print(n.mu, n.sd)
end}

