-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path 
require "lib"
require "random"
require "ok"
require "sample"

ok { sample = function(    s,y)
  rseed(1)
  s = {}
  for i=5,10 do s[i] = sample(2^i) end
  for i=1,10000 do
    y= rand()
    for _,t in pairs(s) do sampleInc(t, y) end 
  end
  for _,t in pairs(s) do 
    print(t.max, nth(t, 0.5)) 
    assert( close( nth(t,0.5), 0.5, 0.25))
  end
end }
