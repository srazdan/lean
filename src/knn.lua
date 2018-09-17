-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "distance"
require "rows"
require "sk"
require "xtiles"

--<tiny><pre style="font-size: 10px; line-height:10px;">
--  rank                                        5     25     50     75     95   k  samples
--  ----  -----------                           -     --     --     --     --   -  -------
--  #1     - *   ------- |                      1      3      7     15     31   8  512
--         - *  -------  |                      1      3      7     14     27   4  256
--         - *  -------  |                      1      3      7     14     28   4  512
--         - *  ------   |                      1      3      7     14     26   1  512
--         -  *  -----   |                      1      3      8     15     26   2  512
--         -  * -------- |                      1      3      8     14     30   8  256
--         -  * -------- |                      1      3      8     14     29   2  256
--         -  *  ------- |                      1      3      8     15     31   1  256
--         -  *  --------|                      1      4      8     15     32   2  128
--         -  *  ------- |                      1      4      9     15     29   8  128
--         -  *   -------|                      1      4      9     17     32   4  128
--         -  *  ------- |                      1      4      9     15     29   1  128
--         -- *   -------|-                     1      5      9     18     38   1  32
--         -  *  --------|-                     1      4      9     16     36   2  64
--         -   *  -------|                      1      4     10     18     34   4  64
--         -   *  -------|                      1      4     10     18     35   2  32
--         --  *  -------|                      1      5     10     18     35   4  32
--         -   *  -------|-                     1      4     10     17     38   8  64
--         -   * --------|-                     1      4     10     16     36   1  64
--         --  *  -------|-                     1      5     10     19     37   8  32
--         --  *  -------|--                    1      6     11     18     40   8  16
--         --  *  -------|---                   1      6     11     19     41   2  16
--         --  *   ------|--                    1      5     11     20     40   4  16
--  #2     --   *  ------|---                   1      6     12     20     41   1  16
--</pre></tiny>

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
  for _,samples in pairs{16,32,64,128,256,512} do
    for _,k in pairs{1,2,4,8} do
      Lean = Lean0()
      Lean.distance.samples= samples
      Lean.distance.k      = k
      s = sample(math.huge)
      s.txt= k..","..samples
      all[ #all+1 ] = s
      for _,row in pairs(data.rows) do
        want = row[#data.name]
        got  = knn(data,row, #data.name) 
        if type(want) == 'number' then
           sampleInc(s, 100*abs(want-got))
        else
          fy(want == got and "." or "X") 
        end
      end 
    end end
  print("rank, ,    5,   25,   50,   75,   95,k,samples")
  print("----,----------- ,    -,   --,   --,   --,   --,-,-------")
	xtileSamples(sk(all),{num="%5s",width=30})
  Lean=Lean0()
end

return {main = function() knns(rows()) end}
