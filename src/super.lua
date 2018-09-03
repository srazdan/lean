-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"

-- This code rewrites the contents of
-- the numeric independent variables as ranges (e.g. 23:45).
-- Such columns `c` are sorted then explored for a `cut` where
-- the expected value of the variance after cutting is 
-- minimized. Note that this code endorses a cut only if:
--
-- - _Both_ the expected value of
--   the standard deviation of `c` and the goal column
--   `goal` are  minimized
-- - The minimization is create than some trivially
--   small change (defaults to 5%, see `Lean.super.margin`);
-- - The number of items in each cut is greater than 
--   some magic constant `enough` (which defaults to
--   the square root of the number of rows, see
--   `Lean.super.enough`)
--
-- After finding a cut, this code explores both 
-- sides of the cut for recursive cuts.
-- 
-- Important note: this code **rewrites** the table
-- so the only thing to do when it terminates is
-- dump the new table and quit.

function super(data,goal,enough,       rows,most)
  rows   = data.rows
  goal   = goal or #(rows[1])
  enough = enough or (#rows)^Lean.super.enough 

-- -------------------------------------------
-- Some low level details. If the `lo`, `hi`
-- points of a range are `?` then search inwards
-- for the most and least none `?` values.


  local function band(c,lo,hi)
    if lo==1 then
      return ":".. rows[hi][c]
    elseif hi == most then
      return rows[lo][c]..":"
    else
      return rows[lo][c]..":"..rows[hi][c] end
  end

-- Find one best cut, as follows.
--
-- - First all everything to a _right_ counter
--   (abbreviated here as `r`).
-- - Then work from `lo` to `hi` taking away
--   values from the _right_ and adding them
--   to a _left_ counter (abbreviated here as `l`).
-- - Using the information in these _right_ and
--   _left_ counters, work out where the best `cut` is.
-- - If no such `cut` found, return `nil`.
--
-- Tehcnical note: actually, we run two _right_
-- and two _left_ counters:
--
-- - two for the independent column (`xl` and `xr`)
-- - and two for the goal column  (`yl` and `yr`)

  local function argmin(c,lo,hi,     
                          x,xl,xr,bestx,tmpx,
                          y,yl,yr,besty,tmpy,
                          cut,mu) 
    xl,xr = num(), num()
    yl,yr = num(), num()
    for i=lo,hi do 
      numInc(xr, rows[i][c]) 
      numInc(yr, rows[i][goal]) end
    bestx = xr.sd
    besty = yr.sd
    mu    = yr.mu
    if (hi - lo > 2*enough) then
      for i=lo,hi do
        x = rows[i][c]
        y = rows[i][goal]
        numInc(xl, x); numDec(xr, x) 
        numInc(yl, y); numDec(yr, y) 
        if xl.n >= enough and xr.n >= enough then
          tmpx = numXpect(xl,xr) * Lean.super.margin
          tmpy = numXpect(yl,yr) * Lean.super.margin
          if tmpx < bestx then
            if tmpy < besty then
              cut,bestx,besty = i, tmpx, tmpy
      end end end end end
    return cut,mu
  end

-- If we can find one good cut:
--
-- - Then recurse to, maybe, find other cuts. 
-- - Else, rewrite all values in `lo` to `hi` to
--   the same string `s` representing the range..

  local function cuts(c,lo,hi,pre,       cut,txt,s,mu)
    txt = pre..rows[lo][c]..".."..rows[hi][c]
    cut,mu = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      s = band(c,lo,hi)
      fyi(txt.." = "..math.floor(100*mu))
      for r=lo,hi do
        rows[r][c]=s end end
  end

-- Our data sorts such that all the "?" unknown values
-- are pushed to the end. This function tells us
-- where to stop so we don't run into those values.

  function stop(c,t)
    for i=#t,1,-1 do if t[i][c] ~= "?" then return i end end
    return 0
  end

-- For all numeric indpendent columns, sort it and 
-- try to cut it. Dump the results to standard output.

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,rows)
      most = stop(c,rows)
      fyi("\n-- ".. data.name[c] .. " ----------")
      cuts(c,1,most,"|.. ") end end
  print(gsub( cat(data.name,", "), "%$",""))
  dump(rows)
end

-- Main function, if this is called top-level.

return {main=function() return super(rows()) end}
