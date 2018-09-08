-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path 
require "lib"
require "knn"

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
