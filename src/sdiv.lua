#!/usr/bin/env luajit
-- vim: filetype=lua ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------  

require "lib"

function sdiv(data,cols,goal,enough,       rows,most)
  rows   = data.rows
  cols   = cols   or data.x
  goal   = goal   or #(rows[1].cells)
  enough = enough or (#rows)^Lean.super.enough 

  local function band(c,lo,hi)
    if lo==1 then
      return "..".. rows[hi].cells[c]
    elseif hi == most then
      return rows[lo].cells[c]..".."
    else
      return rows[lo].cells[c]..".."..rows[hi].cells[c] end
  end

  local function argmin(lo,hi,c,     
                        x,xl,xr,bestx,tmpx,
                        y,yl,yr,besty,tmpy,
                        x1,n,cut,x1,x1) 
    if (hi - lo > 2*enough) then
      yl,yr = num(), num()
      xl,xr = num(), num()
      for i=lo,hi do 
        ninc(xr, rows[i].cells[c])
        ninc(yr, rows[i].cells[goal])
      end
      n, besty, bestx = yr.n, yr.sd, xr.sd
      for i=lo,hi do
        x = rows[i].cells[c];    ninc(xl, x);  ndec(xr, x) 
        y = rows[i].cells[goal]; ninc(yl, y);  ndec(yr, y) 
        if yl.n >= enough and yr.n >= enough then
          x1 = rows[i+1].cells[c]
          if  x < x1 then
            tmpy = sdXpect(yl, yr) * Lean.super.margin
            if tmpy < besty then
              tmpx = sdXpect(xl, xr) * Lean.super.margin
              if tmpx < bestx then
                cut,bestx,besty = i,tmpx,tmpy end end end end end end
    return cut
  end

  local function cuts(lo,hi,c,pre,       cut,txt,s,mu,sum)
    txt = pre..rows[lo].cells[c]..".."..rows[hi].cells[c]
    cut = argmin(lo,hi,c)
    if cut then
      fyi(txt)
      cuts(lo,   cut, c, pre.."|.. ")
      cuts(cut+1, hi, c, pre.."|.. ")
    else
      s = band(c,lo,hi)
      sum = num()
      for r=lo,hi do
        ninc(sum, rows[r].cells[c])
        rows[r].cells[c]=s end 
      fyi(txt.." ==> "..sum.mu)
      end
  end

  local function div(c,   most)
    colsort(c, rows)
    for most=#rows,1,-1 do 
      if rows[most].cells[c] ~= "?" then 
        fyi("\n-- ".. data.name[c] .. " ----------")
        return cuts(1,most,c,"")  end end
  end

  for _,c  in pairs(cols) do
    if data.nums[c] then div(c) end end
  print(gsub( cat(data.name,", "), "%$","")) 
  dump(rows)
end

-- Main function, if this is called top-level.

return { main = function() sdiv(datas()) end }
