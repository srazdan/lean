-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "lib"
require "ok"
require "xtiles"

ok { lists = function(  t1,t2,t3)
  t1,t2,t3={},{},{}
  rseed(1)
  for i=1,10^4 do
    t1[#t1+1] = rand()^0.5 
    t2[#t2+1] = rand() 
    t3[#t3+1] = rand()^2 
  end
  xtiles({sorted(t1),sorted(t2),sorted(t3)},
         {num="%8.2f",width=20})
end }

ok { samples = function(  s1,s2,s2)
  s1,s2,s3 = sample(), sample(), sample()
  s1.txt="love"
  s2.txt="lovelier"
  s3.txt="lovely"
  rseed(1)
  for i=1,10^4 do
    sampleInc(s1, rand()^0.5 )
    sampleInc(s2, rand() )
    sampleInc(s3, rand()^2 )
  end
  xtileSamples({s1,s2,s3},
               {num="%8.2f",width=20})
end }
return Lean.ok.tries, Lean.ok.fails
