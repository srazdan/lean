-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"

-- For simplicity's sake, we'll use the same `cut`
-- structure for cuts to both discrete and continuous
-- columns. 
-- 
-- - For continous cuts, we use a cute where `lo` and `hi` are different.
-- - For discretes, we use a cut that uses `lo==hi`;
-- - For both kinds of cuts, we'll use
--      - a `stats` slot story statistics in that cut
--      - a `mu` slot to store the mean value of the class variable in that cut

function cut(n, c,lo,hi)
  return {stats=n, mu=n.mu, col=c,lo=lo, hi=hi} end

-- Given a `lo` and `hi` range, it is an engineering decision
-- if the range runs `lo<x<hi` or `lo<=x<=hi` or
-- `lo<=x<hi`. Whatever, just define it once and use it
-- consistently throughout. Also, note one tiny detail 
--
-- - if `lo==hi` then this is a discrete cut (see above).

function withinCut(x,lo,hi, out) 
  hi = hi or lo
  if     x =="?" then return false 
  elseif lo==hi  then return x == lo
  else                return x>= lo and x<hi  end
end

-- To find a number break, sort column `c` 
-- then note that our cuts will be a the `lo`
-- and `hi` and `mid` (median) point.
--
-- - Aside: Of course there is no analagous code for `symBreaks` since
-- discrete columns are already broken up into dsicrete values.

function numBreaks(c,t,     lo,mid,hi)
  t = ksort(c,t)
  lo,mid,hi = 1, math.floor(#t/2), #t
  return t[lo][c], t[mid][c], t[hi][c]
end

-- For numberic column `c`, collect statistics
-- about the goal variable (`y`) above and below the
-- break (at the median point). This generates to
-- `cuts` (one above, and one below).

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

-- For discrete column `c`,   collect statistics
-- about the goal variable (`y`) see for each
-- value on the column. Create one seperate cut
-- for each different value in this column,

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

-- Generate cuts for each indendent column.
-- Sort them by their `mu` score (which is
-- the mean of the goal variable seen in each cut).
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

-- This is a minor detail- just create a pretty
-- print for a cut
function fftClause(cut,t,pre,   suffix)
  suffix = cut.lo == cut.hi and "" or  " < "  .. cut.hi
  print((pre or "if   "), t.name[cut.col],"is", 
        cut.lo..suffix, "==>",math.floor(0.5+ 100*cut.mu))
end 

-- Main program: Find the best cut, divide the data
-- into (a) that which falls into the cut and (b) "otherwise".
-- Print out (a) and recurse on "otheriwse" (stopping
-- after four levels)

function fft(t,d,  pre,cut,otherwise,x,str)
  d = d or 4
  if d <= 0                then return true end
  if #t.rows < Lean.fft.min then return true end
  cut = bestCut(t) 
  fftClause(cut,t,pre)
  otherwise = header(t.name)
  for _,cells in pairs(t.rows) do
    if not withinCut(cells[cut.col], cut.lo, cut.hi) then
      row(otherwise, cells) end end
  return fft(otherwise, d-1, "else")
end

function mainFft() fft(rows()) end

return {main=mainFft}
