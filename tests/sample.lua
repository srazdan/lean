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
  -- create some samples holding 32,64,128... max items
  for i=5,10 do s[i] = sample(2^i) end
  -- 10,000 store the same number in all samples
  for i=1,10000 do
    y= rand()
    for _,t in pairs(s) do sampleInc(t, y) end 
  end
  -- check if any of them are +/- 0.2 of 0.5
  for _,t in pairs(s) do 
    print(t.max, nth(t, 0.5)) 
    assert( close( nth(t,0.5), 0.5, 0.25))
  end
end }
