-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"
require "num"

function unsuper(data,  enough,rows, most)
  rows = data.rows
  enough = (#rows)^Lean.unsuper.enough 

  local function band(c,lo,hi)
    if lo==1 then
      return "..".. rows[hi][c]
    elseif hi == most then
      return rows[lo][c]..".."
    else
      return rows[lo][c]..".."..rows[hi][c] end
  end

  local function argmin(c,lo,hi,     l,r,cut,best ,tmp,x)
    if (hi - lo > 2*enough) then
      l,r = num(), num()
      for i=lo,hi do numInc(r, rows[i][c]) end
      best = r.sd
      for i=lo,hi do
        x = rows[i][c]
        numInc(l, x)
        numDec(r, x)
        if l.n >= enough and r.n >= enough then
          tmp = numXpect(l,r) * Lean.unsuper.margin
          if tmp < best then
            cut,best = i, tmp end end end end  
    return cut
  end

  local function cuts(c,lo,hi,pre,       cut,txt,b)
    txt = pre..tostring(rows[lo][c])..".. "..tostring(rows[hi][c])
    cut = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      b= band(c,lo,hi)
      fyi(txt.." ("..b..")")
      for r=lo,hi do
        rows[r][c]=b end end
  end

  function stop(c,t)
    for i=#t,1,-1 do if t[i][c] ~= "?" then return i end end
    return 0
  end

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,rows)
      most = stop(c,rows)
      fyi("\n-- ".. data.name[c] .. most .. "----------")
      cuts(c,1,most,"|.. ") end end
  print(gsub( cat(data.name,", "), "%$","")) 
  dump(rows)
end

return {main=function() return unsuper(rows()) end}
