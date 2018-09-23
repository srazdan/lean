-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- -----------    

require "lib"
require "rows"
require "sk"
require "xtiles"
require "random"
require "abcd"

function nb(data,cells,enough,   klasses,goal,rows,cols,
	                               m,k,f,guess,n) 
  data._klasses = data._klasses and data._klasses or {}
  goal = goal or data.class or data.name[#data.name]
  rows = rows or data.rows
  cols = cols or data.indeps
  m    = Lean.nb.m
  k    = Lean.nb.k
  f    = #data.rows + k * #data._klasses

  function likelihood(klass,   prior,like,x,y,inc)
    prior = (#klass.rows + k) /f
    like  = math.log(prior)
    for _,c in pairs(cols) do
      x,inc = cells[c],0
      if x ~= "?" then
	      if klass.nums[c] then
	        inc = numPdf(klass.nums[c],x)
          --print(c,inc)
	     else
	        y = klass.syms[c].counts[x] or 0
	        inc = (y + m*prior) / (#klass.rows + m)
	     end
       like = like + math.log(inc) end end 
    return like
  end

  function predict(      h,max,l) 
    max = - math.huge
    for k,klass in pairs(data._klasses) do
      h = h or k
      l = likelihood(klass) 
      if l > max then max,h = l,k end end 
    return h
  end

  function learn(    x)
    x = cells[goal]
    data._klasses[x] = data._klasses[x] or header(data.name)
    row(data._klasses[x], cells)
  end

  if enough then guess = predict() end
  learn()
  return guess
end 

function nbs(data,   all,want,got,log,enough,abcds)
  all={}
  for m=1,4,1 do
    for k=1,4,1 do
      Lean = Lean0()
      Lean.nb.m= m
      Lean.nb.k = k
      log = sample(math.huge)
      log.txt = k.."."..m
      all[ #all+1 ] = log
      for r=1,20 do
        abcds = abcd()
        for n,cells in pairs(shuffle(data.rows)) do
          enough = n >= Lean.nb.enough
          want = cells[#data.name]
          if enough then
            got = nb(data,cells, enough) 
            abcdInc(abcds, want, got) 
          else 
            nb(data,cells, enough) 
          end 
        end
        sampleInc(log,
          abcdReport(abcds)["tested_positive"].pd)
      end
    end
  end
	xtileSamples(sk(all),{num="%5.0f",width=30})
  Lean=Lean0()
end

--       s.txt= k..","..samples..","..tostring(p)..","..kernel
--       all[ #all+1 ] = s
--       for _,row in pairs(data.rows) do
--         want = row[#data.name]
--         got  = knn(data,row, #data.name) 
--         if type(want) == 'number' then
--            sampleInc(s, abs(100*(want-got)))
--         else
--           fy(want == got and "." or "X") 
--   print("rank, ,    5,   25,   50,   75,   95,k,samples,p,kernel")
--   print("----, ,    -,   --,   --,   --,   --,-,-------,---,------")
--   Lean=Lean0()
-- end
-- 

--<tiny><pre style="font-size: 8px; line-height:8px;">
--     rank                                              5     25     50     75     95   k  samples  p          kernel
--     ----                                              -     --     --     --     --   -  -------  ---       ------
--     #1           -   *  -------|-                     1      4      9     17     34   2  32       2          triangle
--</pre></tiny>

function nbInc(data,   data1,want,got,s,all,k,samples,p,kernel)
  s = sample(math.huge)
  k, samples, p,kernel = 2, 20, 2,"triangle"
  s.txt= k..","..samples..","..tostring(p)..","..kernel
  rseed(1)
  for _=1,20 do 
    Lean = Lean0()
    data1 = header(data.name)
    for n,cells in pairs(shuffle(data.rows)) do
      row(data1, cells)
      if n > samples*2 then
         want = cells[#data.name]
         got  = nb(data1,cells, #data.name) 
         if type(want) == 'number' then
           sampleInc(s, abs(100*(want-got)))
         else
           fy(want == got and "." or "X") end end end end
  print("rank, ,    5,   25,   50,   75,   95,k,samples,p,kernel")
  print("----, ,    -,   --,   --,   --,   --,-,-------,---","------")
  xtileSamples(sk({s}),{num="%5.0f",width=30})
  Lean=Lean0()
end

return {main = function() nbs(rows()) end}
