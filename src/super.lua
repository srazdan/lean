-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"
require "num"

function super(data,goal,  enough)
  rows   = data.rows
  goal   = goal or #(rows[1])
  enough = (#rows)^Lean.unsuper.enough 

  local function  band(c,lo,hi,   lo1,hi1,n)
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

  local argmin = function(c,lo,hi,     
                          x,xl,xr,bestx,tmpx,
                          y,yl,yr,besty,tmpy,
                          cut) 
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
        if x ~= "?" then numInc(xl, x) numDec(xr, x) end
        if y ~= "?" then numInc(yl, y) numDec(yr, y) end
        if xl.n >= enough and xr.n >= enough then
          tmpx = numXpect(xl,xr) * Lean.unsuper.margin
          tmpy = numXpect(yl,yr) * Lean.unsuper.margin
          if tmpx < bestx then
            if tmpy < besty then
              cut,bestx,besty = i, tmpx, tmpy
      end end end end end
    return cut
  end

  local function cuts(c,lo,hi,pre,       cut,txt,b,mu)
    txt = pre..rows[lo][c]..".."..rows[hi][c]
    cut = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      b,mu= band(c,lo,hi)
      fyi(txt.." = "..math.floor(100*mu))
      for r=lo,hi do
        if rows[r][c] ~= "?" then rows[r][c]=b end end end
  end

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,rows)
      fyi("\n-- ".. data.name[c] .. " ----------")
      cuts(c,1,#rows,"|.. ") end end
  print(string.gsub(cat(data.name,", "), "%$",""))
  dump(rows)
end

return {main=function() return super(rows()) end}
