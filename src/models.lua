
-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "random"

function someN(t) return t.lo + rand()*(t.hi - t.lo) end
function someD(t) return any(t.all) end

function okN(t,x) return x >= t.lo and x <= t.hi end
function okD(t,x) return member(x,t.all) end

function N(txt, t) 
  return {txt= txt,
          lo = t.lo  or 0, 
          hi = t.hi  or 1, 
	  ok = t.ok  or okN,
          get= t.get or someN } end
function D(txt,lst,t)   
  return {txt= txt,
          all= lst, 
          ok = t.ok  or okD, 
	  get= t.get or someD } end

function repeats(t,r,     n,data,t1)
  n,data = 0,header(map(t, function(z) return z.txt end))
  return function ()
    for n=0,r do
      if n == 0 
	then return data.head, data 
	else 
	  cells, n = {}, n + 1
	  for _,c in pairs(data.indeps) do 
	    cells[#cells+1] = cells[c]:get() end 
	  for _,c in pairs(data.w) do 
	    cells[#t1+1] = cells[c].get(cells) end
	  row(data, cells)
	  return cells, data end end end 
end

function fonseca(txt,r,   m,e)
  m,e = 3,2.71828
  local add=function (x,y) return x+y end
  local dec=function (x,y) return x-y end
  local f0=function(t,f,z) 
    for _,c in pairs(data.indeps) do
      z = z+(f(t[c], 1/math.sqrt(m)))^2 end
    return 1 - e^(-1*z)
  end
  all = {N("x"  , {lo= -4, hi= 4}),
         N("y"  , {lo= -4, hi= 4}),
 	 N("z"  , {lo= -4, hi= 4}),
	 N("<f1", {get=function(t) return f0(t, dec, 0) end}),
	 N("<f2", {get=function(t) return f0(t, inc, 0) end})}

  return function()
    if r > 0 then
      r = r - 1
      return ["x","y","z","<f1","<f2" ]
  end
end
  def abouts(i):
    def f1(row):
      z = sum([( row[col.pos] - 1/math.sqrt(Fonseca.n))**2
               for col in i._decs])
      return 1 - math.e**(-1*z)
    def f2(row):
      z = sum([( row[col.pos] + 1/math.sqrt(Fonseca.n))**2
               for col in i._decs])
      return 1 - math.e**(-1*z)
    return i.ready(decs= [N(str(n), lo= -4, up=4)
                          for n in xrange(Fonseca.n)],
                   objs= [N("<f1", get= f1),
                          N("<f2", get= f2)])
return {main = function() xxx() end}
