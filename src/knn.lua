-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "distance"
require "rows"
require "sk"
require "xtiles"
require "random"


function knn(data,row1,  goal,rows,cols) 
  local function klass(x) return first(x)[goal or data.class] end
  local function gap(x)   return second(x) end
  local function triangular(t,   sum,n,ds,d)  
    sum, ds = 0,0
    for i=1,Lean.distance.k do 
      d   = gap(t[i])
      sum = sum + klass(t[i]) / d
      ds  = ds + 1/d
    end
    return sum/ds
  end 
  local function combine(t,   kernel) --assumes t is sorted
    kernel = Lean.distance.kernel
    k      = Lean.distance.k
    if     kernel=="triangle" then return triangular(t) 
    elseif kernel=="median" then return klass(t[int(k/2)])
    else   return klass(t[1])
    end
  end
  return combine( around(data, row1, rows,cols) ) 
end  

--<tiny><pre style="font-size: 8px; line-height:8px;">
--     rank                                              5     25     50     75     95   k  samples  p    kernel
--     ----                                              -     --     --     --     --   -  -------  ---  ------
--     #1             *-----      |                      0      3      7     13     23   4  512      4    triangle
--                    * ----      |                      1      3      7     14     26   4  512      4    median
--                    * ----      |                      1      3      7     14     26   1  512      4    triangle
--                    * ----      |                      1      3      7     14     26   2  512      4    median
--                    * ------    |                      1      3      7     15     31   4  512      2    median
--                    * ------    |                      1      3      7     15     31   2  512      2    median
--                    * ----      |                      1      3      7     14     26   1  512      2    triangle
--                    * ----      |                      1      3      7     14     26   1  512      2    median
--                    *-----      |                      1      3      7     13     25   4  512      2    triangle
--                  - * -----     |                      1      4      7     13     27   4  128      2    triangle
--                  - *-----      |                      1      3      7     12     24   8  256      2    triangle
--                  - *------     |                      1      4      7     13     27   8  256      4    triangle
--                    *----       |                      1      3      7     13     22   8  512      2    triangle
--                    * -----     |                      1      3      7     14     28   2  512      2    triangle
--                  - *-----      |                      1      4      7     12     25   4  256      2    triangle
--                  - * ------    |                      0      4      7     14     30   4  128      4    triangle
--                  - * ----      |                      1      3      7     14     26   8  128      2    triangle
--                    * -----     |                      1      3      7     14     28   2  512      4    triangle
--                    *-----      |                      0      3      7     13     25   8  512      4    triangle
--                    * -----     |                      0      3      7     14     28   2  256      2    triangle
--                    * -----     |                      1      3      8     14     28   2  256      4    triangle
--                  - * -----     |                      1      4      8     13     27   4  256      4    triangle
--                  - * ------    |                      1      4      8     15     31   4  512      3    triangle
--                  - * -----     |                      1      4      8     15     28   2  128      4    triangle
--                    * -----     |                      1      3      8     15     29   1  256      2    median
--                    * ------    |                      1      3      8     15     31   1  512      4    median
--                    * -----     |                      0      3      8     15     28   2  128      4    median
--                    * ------    |                      1      3      8     14     31   1  256      2    triangle
--                    * ----      |                      1      3      8     15     26   1  256      4    median
--                    * -------   |                      1      3      8     16     33   1  128      2    median
--                    * ------    |                      1      3      8     15     31   2  256      4    median
--                  - * -----     |                      1      3      8     14     28   2  128      2    triangle
--                    * ------    |                      0      3      8     15     31   1  256      4    triangle
--                    * ------    |                      1      3      8     16     32   1  128      4    triangle
--                  - * -----     |                      1      4      8     15     28   8  128      4    triangle
--                  - * ------    |                      1      4      8     16     33   8  256      3    triangle
--                  - *  -------  |                      1      4      8     17     37   2  256      3    triangle
--                  - * -------   |                      1      4      9     16     35   4  256      3    triangle
--                  - * -------   |                      1      4      9     16     35   4  32       2    triangle
--                  - *  -----    |                      1      4      9     17     32   8  32       2    triangle
--                  - *  -----    |                      1      4      9     18     33   2  32       4    triangle
--                  - * ------    |                      1      4      9     15     31   4  256      2    median
--                  - * ------    |                      1      4      9     16     32   1  128      2    triangle
--                    * ------    |                      1      3      9     15     30   4  256      4    median
--                    * -----     |                      1      3      9     15     28   2  256      2    median
--                  - * -------   |                      1      4      9     16     35   2  512      3    triangle
--                    * ------    |                      1      3      9     15     32   2  128      2    median
--                    * ------    |                      1      3      9     16     31   1  128      4    median
--                    * -------   |                      1      3      9     16     33   8  512      4    median
--     #2           - *  -------  |                      1      4      9     17     38   4  512      3    median
--                  - *  ------   |                      1      4      9     17     35   2  32       2    median
--                  - *  ------   |                      1      4      9     17     35   1  512      3    triangle
--                  - *  -------  |                      1      4      9     18     37   1  256      3    triangle
--                  - * -------   |                      1      4      9     16     34   8  512      3    triangle
--                  - *  -------  |                      1      4      9     18     39   4  128      3    triangle
--                  - *  -----    |                      1      4      9     17     33   8  32       4    triangle
--                  - * ------    |                      1      4      9     16     32   2  32       2    triangle
--                  - *  -------  |                      1      5      9     19     39   8  128      3    triangle
--                  - *   --------|                      1      5     10     20     45   2  128      3    triangle
--                  - * -------   |                      1      4     10     16     34   4  32       4    triangle
--                  -  * -------- |                      1      5     10     19     40   1  32       4    median
--                  -  * ------   |                      1      4     10     17     35   2  512      3    median
--                  -  * ------   |                      1      4     10     17     35   1  512      3    median
--                  -  * -------  |                      1      4     10     18     37   1  256      3    median
--                  -  * -----    |                      1      4     10     17     30   4  128      2    median
--                  -  * -------  |                      1      4     10     19     38   1  32       2    triangle
--                  -  * ------   |                      1      4     10     17     35   8  256      4    median
--                  -  *  ------  |                      1      4     10     20     39   1  32       2    median
--                  -  *  ------- |                      1      5     11     20     41   4  256      3    median
--                  -  * -------  |                      1      4     11     18     39   1  128      3    triangle
--                  -  *  ------- |                      1      6     11     20     41   4  32       4    median
--                  -  * ------   |                      1      4     11     18     36   4  128      4    median
--                  -  *  ------  |                      1      5     11     20     39   2  32       4    median
--                  -  * -------  |                      1      4     11     19     39   1  32       4    triangle
--                  -  *  ------- |                      1      4     11     20     42   1  128      3    median
--                  -  *  --------|                      1      5     11     20     44   2  128      3    median
--                  -  *  ------  |                      1      5     11     20     38   8  128      4    median
--                  -  *  ------- |                      1      5     11     21     40   8  128      2    median
--     #3           -  *   -------|--                    1      5     12     26     55   1  32       3    triangle
--                  -  *  --------|                      2      6     12     22     45   4  32       2    median
--                  -  *  --------|                      1      5     12     22     44   8  512      3    median
--                  -  *  --------|                      1      6     12     21     48   4  128      3    median
--                  -  *  --------|                      2      6     12     21     44   8  32       2    median
--                  -  *  --------|                      1      6     12     23     43   4  32       3    triangle
--                  -  *   -------|                      1      6     13     26     49   4  256      1    triangle
--                  -  *  --------|                      1      5     13     23     49   8  256      3    median
--                  -  *   -------|                      1      6     13     26     49   1  128      1    median
--                  -  *   -------|-                     1      6     13     24     51   2  32       3    median
--                  -  *   -------|-                     1      6     13     26     52   8  128      3    median
--                  -  *    ------|--                    1      6     13     27     55   2  256      1    median
--                  -  *    ------|--                    1      6     13     28     55   4  512      1    median
--                  -  *    ------|---                   1      6     13     28     57   8  256      1    median
--                  -  *   -------|-                     1      6     13     24     53   2  32       3    triangle
--                  -  *    ------|----                  1      6     13     28     62   4  256      1    median
--                  -  *   -------|-                     1      6     13     24     50   8  512      1    triangle
--                  -  *   -------|                      1      5     13     25     45   8  256      1    triangle
--                  -   *  -------|---                   1      6     13     26     57   2  256      1    triangle
--                  --  *  -------|                      1      7     14     25     46   8  32       3    triangle
--                  -   *   ------|-                     1      6     14     28     51   2  512      1    triangle
--                  -   *  -------|                      1      6     14     25     47   4  128      1    triangle
--                  --  *  -------|                      1      7     14     24     47   8  128      1    triangle
--                  -   *  -------|                      1      6     14     25     49   4  512      1    triangle
--                  -   *  -------|--                    1      6     14     26     53   2  32       1    triangle
--                  -   *  -------|-                     1      6     14     26     50   1  512      1    triangle
--                  -   *  -------|                      1      6     14     25     46   8  32       4    median
--                  -   *  -------|----                  1      6     14     26     62   8  512      1    median
--                  -   *   ------|---                   1      6     14     28     59   1  128      1    triangle
--                  -   *   ------|----                  1      6     14     28     62   4  128      1    median
--                  -   *    -----|----                  1      6     14     30     60   8  128      1    median
--                  --  *   ------|---                   1      7     14     27     59   1  32       3    median
--                  --  *   ------|---                   1      7     14     26     57   2  128      1    triangle
--                  --  *   ------|--                    1      7     15     29     53   1  32       1    triangle
--                  -   *    -----|---                   2      6     15     30     57   1  256      1    median
--                  -   *    -----|--                    2      6     15     30     53   2  512      1    median
--                  -   *   ------|                      1      6     15     27     49   4  32       1    triangle
--                  --  *   ------|                      1      8     16     29     49   8  32       1    triangle
--                  --  *   ------|-                     1      8     16     28     51   1  512      1    median
--                  --  *    -----|---                   1      7     16     31     58   1  256      1    triangle
--                  --  *   ------|-                     1      7     16     28     52   2  128      1    median
--                  --  *    -----|---                   1      7     16     31     58   1  32       1    median
--                  --  *    -----|---                   1      8     16     32     59   2  32       1    median
--                  --   *    ----|-----                 1      8     17     34     63   4  32       1    median
--     #4           --   *    ----|----                  2      7     17     34     62   4  32       3    median
--                  --   *     ---|------                2      9     19     39     69   8  32       1    median
--                  ---   *     --|-------               3     10     22     41     71   8  32       3    median
--     -- warning   rogue local [k]
--</pre></tiny>

function knns(data,   want,got,s,all)
  all={}
  for _,kernel in pairs{"median","triangle"} do
  for p=1,4,1 do
   for _,samples in pairs{32,128,256,512} do
    for _,k in pairs{1,2,4,8} do
      Lean = Lean0()
      Lean.distance.kernel= kernel
      Lean.distance.samples= samples
      Lean.distance.p=p
      Lean.distance.k      = k
      s = sample(math.huge)
      s.txt= k..","..samples..","..tostring(p)..","..kernel
      all[ #all+1 ] = s
      for _,row in pairs(data.rows) do
        want = row[#data.name]
        got  = knn(data,row, #data.name) 
        if type(want) == 'number' then
           sampleInc(s, abs(100*(want-got)))
        else
          fy(want == got and "." or "X") end end end end end end
  print("rank, ,    5,   25,   50,   75,   95,k,samples,p,kernel")
  print("----, ,    -,   --,   --,   --,   --,-,-------,---,------")
	xtileSamples(sk(all),{num="%5.0f",width=30})
  Lean=Lean0()
end

--<tiny><pre style="font-size: 8px; line-height:8px;">
--     rank                                              5     25     50     75     95   k  samples  p          kernel
--     ----                                              -     --     --     --     --   -  -------  ---       ------
--     #1           -   *  -------|-                     1      4      9     17     34   2  32       2          triangle
--</pre></tiny>

function knnsInc(data,   data1,want,got,s,all,k,samples,p,kernel)
  s = sample(math.huge)
  k, samples, p,kernel = 2, 32, 2,"triangle"
  s.txt= k..","..samples..","..tostring(p)..","..kernel
  rseed(1)
  for _=1,20 do 
    Lean = Lean0()
    data1 = header(data.name)
    Lean.distance.p = p
    Lean.distance.k = k
    Lean.distance.kernal = kernel
    Lean.distance.samples = samples
    for n,cells in pairs(shuffle(data.rows)) do
      row(data1, cells)
      if n > samples*2 then
         want = cells[#data.name]
         got  = knn(data1,cells, #data.name) 
         if type(want) == 'number' then
           sampleInc(s, abs(100*(want-got)))
         else
           fy(want == got and "." or "X") end end end end
  print("rank, ,    5,   25,   50,   75,   95,k,samples,p,kernel")
  print("----, ,    -,   --,   --,   --,   --,-,-------,---","------")
	xtileSamples(sk({s}),{num="%5.0f",width=30})
  Lean=Lean0()
end

return {main = function() knnsInc(rows()) end}
