-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "sk"
require "ok"

function skTest(   a,b,c,d,e,g,r,f)
  rseed(1)
	a,b,c= sample(), sample(), sample()
	d,e,g= sample(), sample(), sample()
  a.txt="apples"
  b.txt="berries"
  c.txt="candles"
  d.txt="dapples"
  e.txt="everyready"
  g.txt="family"
  f=function(z) return math.floor(100*z) end
	for i=1,100 do 
		r= rand()
		sampleInc(a,f(r^2.3))
		sampleInc(b,f(r^2.7))
		sampleInc(c,f(r^0.3)) 
		sampleInc(d,f(r^0.7))
		sampleInc(e,f(r^0.9))
		sampleInc(g,f(r^1.1)) 
  end
	xtileSamples(sk{a,b,c,d,e,g},
               {num="%4s",width=25})
end 

skTest()
--ok {sk = skTest}

