-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"

function cut(n, c,lo,hi)
  return {stats=n, mu=n.mu, col=c,lo=lo, hi=hi} end

function withinCut(x,lo,hi, out) 
  hi = hi or lo
  if     x =="?" then return false 
  elseif lo==hi  then return x == lo
  else                return x>= lo and x<hi  end
end

function numBreaks(c,t,     lo,mid,hi)
  t = ksort(c,t)
  lo,mid,hi = 1, #t//2, #t
  return t[lo][c], t[mid][c], t[hi][c]
end

function numCuts(t,c,goal,cuts,    
                      lo,mid,hi,above,below,what,x,y)
  lo,mid,hi = numBreaks(c,t.rows) 
  above     = num()
  below     = num()
  for _,cells in pairs(t.rows) do
     x = cells[c]
     y = cells[goal]
     what = withinCut(x ,lo,mid) and below or above
     numInc(what, y) end
  cuts[ #cuts+1 ] = cut(below, c,  lo, mid)
  cuts[ #cuts+1 ] = cut(above, c, mid, hi)
end

function symCuts(t,c,goal,cuts,     tmp,x,y)
  tmp = {}
  for _,cells in pairs(t.rows) do
    x = cells[c]
    y = cells[goal]
    tmp[x] = tmp[x] or num()
    numInc( tmp[x], y )
  end
  for v,n in pairs(tmp) do
      cuts[ #cuts+1 ] = cut(n,c,v,v) end
end

function bestCut(t,   cuts,goal)
  cuts = {}
  goal = #t.name
  for c,name in pairs(t.name) do
    if indep(t,c) then
      if t.nums[c] 
      then numCuts(t,c,goal,cuts)
      else symCuts(t,c,goal,cuts) end end end
  cuts = ksort("mu", cuts)
  return cuts[#cuts] 
end

function fftClause(cut,t,pre,   suffix)
  suffix = cut.lo == cut.hi and "" or  " < "  .. cut.hi
  print((pre or "if   "), t.name[cut.col],"is", 
        cut.lo..suffix, "==>",math.floor(0.5+ 100*cut.mu))
end 

function fft(t,d,  pre,cut,otherwise,x,str)
  d = d or 4
  if d <= 0                then return true end
  if #t.rows < The.fft.min then return true end
  cut = bestCut(t) 
  fftClause(cut,t,pre)
  otherwise = names2data(t.name)
  for _,cells in pairs(t.rows) do
    if not withinCut(cells[cut.col], cut.lo, cut.hi) then
      row(otherwise, cells) end end
  return fft(otherwise, d-1, "else")
end

function mainFft() fft(rows()) end

return {main=mainFft}
