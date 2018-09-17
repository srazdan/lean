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

--<tiny><pre style="font-size: 9px; line-height:9px;">
--      rank                                        5     25     50     75     95   k  samples  p
--      ----  -----------                           -     --     --     --     --   -  -------  ---
--      #1       * -----     |                      1      3      7     14     27   4  512      4
--               * ------    |                      1      3      7     15     31   2  512      2
--               * ----      |                      1      3      7     14     26   2  512      4
--               * -----     |                      1      3      7     14     27   8  512      4
--               * ------    |                      1      3      7     14     31   8  256      4
--               * ------    |                      1      3      7     15     30   4  256      4
--               * ----      |                      1      3      7     14     26   1  512      2
--               * -----     |                      1      3      8     15     29   1  256      2
--               * ------    |                      1      3      8     15     31   1  512      4
--               * ----      |                      1      3      8     15     26   1  256      4
--               * -----     |                      1      3      8     15     28   4  512      2
--               * ----      |                      1      3      8     15     25   8  256      2
--               * -----     |                      0      3      8     15     28   2  128      4
--               * -------   |                      1      3      8     16     33   1  128      2
--               * ------    |                      1      3      8     15     31   8  512      2
--               * ------    |                      1      3      8     15     31   2  256      4
--             - * ------    |                      1      4      8     15     30   4  256      2
--             - * ------    |                      1      4      9     15     32   8  128      4
--               * ------    |                      1      3      9     16     31   1  128      4
--             - * ------    |                      1      4      9     15     33   4  128      2
--               * -----     |                      1      3      9     15     28   2  256      2
--               * ------    |                      1      3      9     15     32   2  128      2
--             - *  -------  |                      1      4      9     17     37   2  256      3
--             - *  -----    |                      1      4      9     17     33   4  128      4
--             - *  ------   |                      1      4      9     17     35   2  32       2
--      #2     -  * ------   |                      1      4     10     17     35   4  512      3
--             -  * ------   |                      1      4     10     17     35   2  512      3
--             -  * -------  |                      1      4     10     18     37   1  256      3
--             -  * -------  |                      1      4     10     18     37   4  256      3
--             -  * ------   |                      1      4     10     17     35   1  512      3
--      #1     -  * -------- |                      1      5     10     19     40   1  32       4
--             -  * ------   |                      1      4     10     17     35   8  128      2
--             -  * -------  |                      1      4     10     17     37   8  512      3
--      #2     -  * -------- |                      1      5     10     19     41   4  128      3
--             -  *  ------  |                      1      5     10     20     39   8  256      3
--             -  *  ------  |                      1      4     10     20     39   1  32       2
--             -  *  ------  |                      1      5     10     21     39   4  32       4
--             -  *  ------- |                      1      4     11     20     42   1  128      3
--             -  * ------   |                      1      5     11     18     35   4  32       2
--             -  * ------   |                      1      5     11     18     34   8  32       2
--             -  * -------  |                      1      4     11     19     39   8  32       4
--             -  *  ------  |                      1      5     11     20     39   2  32       4
--             -  * ---------|                      1      5     11     19     44   8  128      3
--             -  *  --------|                      1      5     11     20     44   2  128      3
--      #3     -  *   -------|                      1      5     12     24     49   4  32       3
--             -  *   -------|----                  1      6     13     26     61   8  32       3
--             -  *   -------|                      1      6     13     26     49   1  128      1
--             -  *   -------|-                     1      6     13     24     51   2  32       3
--             -  *    ------|--                    1      6     13     27     55   2  256      1
--             --  *   ------|---                   1      7     14     27     58   8  128      1
--             -   *   ------|--                    1      6     14     27     56   8  256      1
--             -   *   ------|---                   1      6     14     28     59   4  128      1
--             --  *   ------|---                   1      7     14     27     59   1  32       3
--             --  *  -------|-                     1      7     14     26     51   4  256      1
--             --  *   ------|--                    1      7     15     28     55   8  512      1
--             -   *    -----|---                   2      6     15     30     57   1  256      1
--             --  *   ------|-                     1      7     15     29     50   4  512      1
--             -   *    -----|--                    2      6     15     30     53   2  512      1
--             -   *    -----|--                    1      6     15     32     55   8  32       1
--             --  *   ------|-                     1      8     16     28     51   1  512      1
--             -   *    -----|-----                 1      6     16     31     63   4  32       1
--             --  *   ------|-                     1      7     16     28     52   2  128      1
--             --  *    -----|---                   1      7     16     31     58   1  32       1
--             --  *    -----|---                   1      8     16     32     59   2  32       1
--</pre></tiny>

function knns(data,   want,got,s,all)
  all={}
  for p=1,4,1 do
   for _,samples in pairs{32,128,256,512} do
    for _,k in pairs{1,2,4,8} do
      Lean = Lean0()
      Lean.distance.p=p
      Lean.distance.samples= samples
      Lean.distance.k      = k
      s = sample(math.huge)
      s.txt= k..","..samples..","..tostring(p)
      all[ #all+1 ] = s
      for _,row in pairs(data.rows) do
        want = row[#data.name]
        got  = knn(data,row, #data.name) 
        if type(want) == 'number' then
           sampleInc(s, 100*abs(want-got))
        else
          fy(want == got and "." or "X") end end end end end
  print("rank, ,    5,   25,   50,   75,   95,k,samples,p")
  print("----,----------- ,    -,   --,   --,   --,   --,-,-------,---")
	xtileSamples(sk(all),{num="%5s",width=30})
  Lean=Lean0()
end

--<tiny><pre style="font-size: 9px; line-height:9px;">
--      rank                                        5     25     50     75     95   k  samples  p
--      --  -----------                           -     --     --     --     --   -  -------  ---
--      #1     --  *  -------|--                    1      5     10     18     37   2  32       2
--</pre></tiny>

function knnsInc(data,   data1,want,got,s,all,k,samples,p)
  s = sample(math.huge)
  k, samples, p = 2, 32, 2
  s.txt= k..","..samples..","..tostring(p)
  for _=1,20 do 
    Lean = Lean0()
    data1 = header(data.name)
    Lean.distance.p = p
    Lean.distance.k = k
    Lean.distance.samples = samples
    for n,cells in pairs(shuffle(data.rows)) do
      row(data1, cells)
      if n > samples*2 then
         want = cells[#data.name]
         got  = knn(data1,cells, #data.name) 
         if type(want) == 'number' then
           sampleInc(s, 100*abs(want-got))
         else
           fy(want == got and "." or "X") end end end end
  print("rank, ,    5,   25,   50,   75,   95,k,samples,p")
  print("----,----------- ,    -,   --,   --,   --,   --,-,-------,---")
	xtileSamples(sk({s}),{num="%5s",width=30})
  Lean=Lean0()
end

return {main = function() knnsInc(rows()) end}
