-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "distance"
require "rows"
require "sk"
require "xtiles"

function knn(data,row1,  goal,rows,cols) 
  local function klass(x) return first(x)[goal or data.class] end
  local function gap(x)   return second(x) end
  local function triangular(t,   sum,n,ds)  
    sum, ds = 0,0
    for i=1,Lean.distance.k do 
      d   = gap(t[i])
      sum = sum + klass(t[i]) / d
      ds  = ds + 1/d
    end
    return sum/ds
  end 
  local function combine(t,   kernel)
    kernel = Lean.distance.kernel
    if     kernel=="triangluar" then return triangular(t) 
    elseif kernel=="median" then return klass(t[int(#k/2)])
    else   return klass(t[1])
    end
  end
  return combine( around(data, row1, rows,cols) ) 
end  

function knns(data,   want,got,s,all)
  all={}
  for _,samples in pairs{16,32,64,128} do
    for _,k in pairs{1,2,4,8} do
      Lean = Lean0()
      Lean.distance.samples= samples
      Lean.distance.k      = k
      s = sample(samples)
      s.txt= "k"..k..",s"..samples
      all[ #all+1 ] = s
      for _,row in pairs(data.rows) do
        want = row[#data.name]
        got  = knn(data,row, #data.name) 
        if type(want) == 'number' then
           sampleInc(s, int(100*(want-got)/(want+10^-32)))
        else
          fy(want == got and "." or "X") 
        end
      end 
    end end
	xtileSamples(sk(all))
  Lean=Lean0()
end

return {main = function() knns(rows()) end}
