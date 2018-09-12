-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "sk"
require "ok"

function skTest(   a,b,c,r)
	a,b,c= sample(), sample(), sample()
  a.txt="apples"
  b.txt="berries"
  c.txt="candles"
	for i=1,1000 do 
		r= rand()
		sampleInc(a,r^2)
		sampleInc(b,r)
		sampleInc(c,r^0.5) end
	xtileSamples(sk{a,b,c})
end 

skTest()
--ok {sk = skTest}

