-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ----:w
-------  

require "lib"
require "rows"
require "sk"
require "xtiles"
require "random"
require "abcd"

function nb(data,row,      klasses,goal,rows,cols,
	                   m,k,f,h,like,max) 
  goal = goal or data.class or data.name[#data.name]
  rows = rows or data.rows
  cols = rows or data.indeps
  m    = Lean.nb.m
  k    = Lean.nb.k
  f    = #data.rows + k * #klasses
  data._klasses = data._klasses and data._klasses or {}

  function predict(klass,   prior,like,x,y,inc)
    prior = (#klass.rows + k) /f
    like  = math.log(prior)
    for c in pairs(cols) do
      x,inc = row[c],0
      if x ~= "?" then
	if data.nums[c] then
	  inc = math.log(numPdf(t.nums[c],x))
	else
	  y = t.syms[c].counts[x] or 0
	  inc = (y + m*prior) / (#klass.rows + m)
	end
        like = like + math.log(inc) end end 
    return like
  end

  function train(row,  x)
    x = row[goal]
    
  end
  like,max = 0,0
  for h1,klass in pairs(klasses) do
    h = h or h1
    l = likes(klass) 
    if l > max then max,h = l,h1 end end 
  return h
end

  -----------------------------------------------------
  function likes(row, t, m, k, funnyFudgeFactor)
    local prior = (#t.rows  + k) / funnyFudgeFactor
    local like  = math.log(prior)
    for i,col in pairs(t.columns.x) do
      local x, inc = row.x[i]
      if x ~= t.ignore then
	if numcol(col) then
	  like= like + math.log(normpdf(x,col.log))
	else
	  local f = col.log.counts[x] or 0
	  like= like +
	        math.log((f + m*prior) / (#t.rows + m))
    end end end
    return like
  end
  -----------------------------------------------------
  local function predict(row,t,m,k,h)
    local max = -10 ^ 32
    for h1,t1 in pairs(t.subs) do
      local l = likes(row, t1, m, k,
		      #data.rows + k * t.h)
      if l > max then
	max, h = l, h1
    end end
    return h
  end
  -----------------------------------------------------
  function nb(opts)
    local opts, abcd = opts or nb0(), abcd0()
    local t
    print("#", opts)
    for i,names,row in xys() do
      if i > opts.enough then
	local mode = t.columns.y[1].log.mode
	local want = row.y[1]
	local got  = predict(row,t, opts.m,opts.k, mode)
	abcd1(want, got, abcd)
      end
      t = sample1(row,t,names)

    end
    return abcd
  end
end

function nbs(data,   want,got,s,all)
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
        got  = nb(data,row, #data.name) 
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

function nbInc(data,   data1,want,got,s,all,k,samples,p,kernel)
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

return {main = function() nbInc(rows()) end}
