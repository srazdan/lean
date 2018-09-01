-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"
require "num"

function unsuper(data,  enough)
  enough = (#data.rows)^Lean.unsuper.enough 
 
  local argmin = function(c,lo,hi,     l,r,cut,best ,tmp,x)
    if (hi - lo > 2*enough) then
      l,r = num(), nums(rows, function(row) return row[c] end)
      best = r.sd
      for i=lo,hi do
        x = data.rows[i][c]
        numInc(l, x)
        numDec(r, x)
        if l.n >= enough and r.n >= enough then
          tmp = numExpect(l,r) * Lean.unsuper.margin
          if tmp < best then
            cut,best = i, tmp end end end end
    return cut
  end

  local function cuts(c,lo,hi,pre,       cut,r,txt,band)
    txt = pre..data.rows[lo][c]..".. "..data.rows[hi][c]
    cut = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      fyi(txt.."("..(hi-lo)..")")
      band = rows[lo][c]..":"..rows[hi][c]
      for r=lo,hi do rows[r][c] = band end end
  end

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,data.rows)
      cuts(c,1,#data.rows,"|.. ") end end
  print(string.gsub(cat(data.name,", "), "%$",""))
  dump(data.rows)
end

return {main=function() return unsuper(rows()) end}
