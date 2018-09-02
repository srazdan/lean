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

function super(data,goal,enough,       rows)
  rows   = data.rows
  goal   = goal or #(rows[1])
  enough = enough or (#rows)^Lean.super.enough 

-- -------------------------------------------
-- Some low level details. If the `lo`, `hi`
-- points of a range are `?` then search inwards
-- for the most and least none `?` values.

  local function  range(c,lo,hi,   lo1,hi1,n)
    lo1,hi1 = lo,hi
    for r=lo,hi do 
     if rows[r][c] ~= "?" then lo1 = r; break; end end
    for r=hi,lo,-1 do
     if rows[r][c] ~= "?" then hi1 = r; break; end end
    n = num()
    for r=lo,hi do
      numInc(n, rows[r][goal]) end
    return rows[lo1][c]..":"..rows[hi1][c], n.mu
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
    if (hi - lo > 2*enough) then
      xl,xr = num(), num()
      yl,yr = num(), num()
      for i=lo,hi do 
        numInc(xr, rows[i][c]) 
        numInc(yr, rows[i][goal]) end
      bestx = xr.sd
      besty = yr.sd
      mu    = yr.mu
      for i=lo,hi do
        x = rows[i][c]
        y = rows[i][goal]
        if x ~= "?" then numInc(xl, x);numDec(xr, x) end
        if y ~= "?" then numInc(yl, y);numDec(yr, y) end
        if xl.n >= enough and xr.n >= enough then
          tmpx = numXpect(xl,xr) * Lean.super.margin
          tmpy = numXpect(yl,yr) * Lean.super.margin
          if tmpx < bestx then
            if tmpy < besty then
              cut,bestx,besty = i, tmpx, tmpy
      end end end end end
    return cut
  end

-- If we can find one good cut:
--
-- - Then recurse to, maybe, find other cuts. 
-- - Else, rewrite all values in `lo` to `hi` to
--   the same string `s` representing the range..

  local function cuts(c,lo,hi,pre,       cut,txt,s,mu)
    txt = pre..rows[lo][c]..".."..rows[hi][c]
    cut = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      s,mu= range(c,lo,hi)
      fyi(txt.." = "..math.floor(100*mu))
      for r=lo,hi do
        if rows[r][c] ~= "?" then rows[r][c]=s end end end
  end

-- For all numeric indpendent columns, sort it and 
-- try to cut it. Dump the results to standard output.

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,rows)
      fyi("\n-- ".. data.name[c] .. " ----------")
      cuts(c,1,#rows,"|.. ") end end
  print(string.gsub(cat(data.name,", "), "%$",""))
  dump(rows)
end

-- Main function, if this is called top-level.

return {main=function() return super(rows()) end}
