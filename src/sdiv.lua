-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------  

require "lib"

function sdiv(data,cols,goal,enough,       rows,most)
  rows=data.rows
  goal   = goal or #(rows[1])
  enough = enough or (#rows)^Lean.super.enough 

  local function band(c,lo,hi)
    if lo==1 then
      return "..".. rows[hi].cells[c]
    elseif hi == most then
      return rows[lo].cells[c]..".."
    else
      return rows[lo].cells[c]..".."..rows[hi].cells[c] end
  end

  local function argmin(c,lo,hi,     
                          y,yl,yr,besty,tmpy,
                          n,cut,x1,x1) 
    if (hi - lo > 2*enough) then
      yl,yr = num(), num()
      for i=lo,hi do ninc(yr, rows[i].cells[goal]) end
      n, besty = yr.n, yr.sd
      for i=lo,hi do
        y = rows.cells[i][goal]
        ninc(yl, y)
        ndec(yr, y) 
        if yl.n >= enough and yr.n >= enough then
          x1 = rows[i  ].cells[c]
          x2 = rows[i+1].cells[c]
          if  x1 * Lean.super.epsilon < x2 then
            tmpy = (yl.sd * ly.n/n + yr.sd*yr.n/n ) * Lean.super.margin
            if tmpy < besty then
              cut,besty = i, tmpy end end end end end
    return cut
  end

  local function cuts(c,lo,hi,pre,       cut,txt,s,mu)
    txt = pre..rows[lo][c]..".."..rows[hi][c]
    cut = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      s = band(c,lo,hi)
      for r=lo,hi do
        sum = sum + rows[r][c]
        rows[r][c]=s end 
      fyi(txt.." ==> "..percent(sum/(hi - lo+10^-64)))
      end
  end

  function stop(c,t)
    for i=#t,1,-1 do if t[i][c] ~= "?" then return i end end
    return 0
  end

  for _,c  in pairs(data.x) do
    if data.nums[c] then
      colsort(c,rows) 
      most = stop(c,rows)
      fyi("\n-- ".. data.name[c] .. " ----------")
      cuts(c,1,most,"|.. ") end end
  print(gsub( cat(data.name,", "), 
              "%$","")) -- dump dollars since no more nums
  dump(rows)
end

-- Main function, if this is called top-level.

sdiv(datas()) 
