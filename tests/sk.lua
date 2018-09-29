-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "sk"
require "ok"

function sk0(ts, ss,s)
  ss={}
  for _,t in pairs(ts) do
    s=sample()
    s.txt=t[1]
    for i=2,#t do
      sampleInc(s, t[i]) end
    ss[#ss+1]=s end
	xtileSamples(sk(ss),
               {num="%6.2f",width=25}) end

ok { sk1= function()
  sk0{ {"x1",0.34, 0.49, 0.51, 0.6},
       {"x2",6,  7,  8,  9}} end}

ok { sk2= function()
  sk0{{"x1",0.1,  0.2,  0.3,  0.4},
  {"x2",0.1,  0.2,  0.3,  0.4},
  {"x3",6,  7,  8,  9}} end}

ok { sk3= function()
        sk0{{"x1",0.34, 0.49, 0.51, 0.6},


        {"x2",0.6,  0.7,  0.8,  0.9},
        {"x3",0.15, 0.25, 0.4,  0.35},
        {"x4",0.6,  0.7,  0.8,  0.9},
        {"x5",0.1,  0.2,  0.3,  0.4} } end }

ok { sk4 = function()
  sk0{{"x1",101, 100, 99,   101,  99.5},
      {"x2",101, 100, 99,   101, 100},
      {"x3",101, 100, 99.5, 101,  99},
      {"x4",101, 100, 99,   101, 100} } end }

ok { sk5 = function() 
      sk0{{"x1",11,11,11},
      {"x2",11,11,11},
      {"x3",11,11,11}} end }

ok { sk6 = function()
  sk0{{"x1",11,11,11},
  {"x2",11,11,11},
  {"x4",32,33,34,35}} end }

ok { sk100 = function(   s,ss,r,f)
  s=20
  r=100
  ss={}
  rseed(1)
	for i=1,s do
    ss[i] = sample()
    ss[i].txt = "sample "..i
  end
  f=function(z) return math.floor(100*z) end
	for j=1,r do
    for i,x in pairs(ss) do
      r=rand()
      if i % 2 == 0 
        then sampleInc( x,  f(r^i)) 
        else sampleInc( x,  f(r^(1/i)))  end
    end end
	xtileSamples(sk(ss),
               {num="%4s",width=25})
             end }
return Lean.ok.tries, Lean.ok.fails
