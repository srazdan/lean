-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"
require "num"

function unsuper(data,  enough,rows)
  rows = data.rows
  enough = (#rows)^Lean.unsuper.enough 

  local function  band(c,lo,hi,   lo1,hi1)
    lo1,hi1 = lo,hi
    for r=lo,hi do 
     if rows[r][c] ~= "?" then lo1 = r; break; end end
    for r=hi,lo,-1 do
     if rows[r][c] ~= "?" then hi1 = r; break; end end
    return rows[lo1][c]..":"..rows[hi1][c]
  end

  local argmin = function(c,lo,hi,     l,r,cut,best ,tmp,x)
    if (hi - lo > 2*enough) then
      l,r = num(), num()
      for i=lo,hi do numInc(r, rows[i][c]) end
      best = r.sd
      for i=lo,hi do
        x = rows[i][c]
        if x ~= "?" then
          numInc(l, x)
          numDec(r, x)
          if l.n >= enough and r.n >= enough then
            tmp = numXpect(l,r) * Lean.unsuper.margin
            if tmp < best then
              cut,best = i, tmp end end end end end
    return cut
  end

  local function cuts(c,lo,hi,pre,       cut,txt,b)
    txt = pre..rows[lo][c]..".. "..rows[hi][c]
    cut = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      b= band(c,lo,hi)
      fyi(txt.." ("..b..")")
      for r=lo,hi do
        if rows[r][c] ~= "?" then rows[r][c]=b end end end
  end

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,rows)
      fyi("\n-- ".. c .. "----------")
      cuts(c,1,#rows,"|.. ") end end
  print(string.gsub(cat(data.name,", "), "%$",""))
  dump(rows)
end

return {main=function() return unsuper(rows()) end}
