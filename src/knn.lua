-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "distance"
require "rows"

function knn(data,k,row1,  goal,samples,kernel,rows,   some) 
  local function combine(t)
    local function triangular(t,   sum,n)  
      sum, n = 0,0
      for i=1,#t do sum=sum+ first(t[i]) / second(t[i]) end
      for i=1,#t do n  =n  + 1/second(t[i]) end
      return sum/n
    end 
    kernel = kernel or Lean.distance.kernel
    if     kernel=="triangluar" then return triangular(t) 
    elseif kernel=="median" then return first(t[int(#t/2)])
    else   return first(t[1])
    end
  end

  some = around(data, row1 or any(rows), rows or data.rows,
                      samples) 
  return combine(splice(some, 1, k or Lean.distance.k, 
                        function(z) return  {
                          first(z)[goal or data.class], 
                          second(z)} end))
end  

function knnDemo(data,   want,got,s)
  for _,n in pairs{16,32,64,128} do
    for _,k in pairs{1,2,4,8} do
      s=sample()
      for _,row in pairs(data.rows) do
        want = row[#data.name]
        got  = knn(data,k,row, #data.name,n) 
        if type(want) == 'number' then
           sampleInc(s, int(100*(want-got)/(want+10^-32)))
        else
          fy(want == got and "." or "X") 
        end
      end 
      if s.n > 0 then print(n..","..
  	                  k..","..cat(nths(s),",")) end
    end end
end

return {main = function() knnDemo(rows()) end}
