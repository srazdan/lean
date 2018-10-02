-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- ---------  

require "lib"

function super(data,goal,enough,       rows,most)
  rows   = data.rows
  goal   = goal or #(rows[1])
  enough = enough or (#rows)^Lean.super.enough 

  local function band(c,lo,hi)
    if lo==1 then
      return "..".. rows[hi][c]
    elseif hi == most then
      return rows[lo][c]..".."
    else
      return rows[lo][c]..".."..rows[hi][c] end
  end

  local function argmin(c,lo,hi,     
                          y,yl,yr,besty,tmpy,
                          cut,mu) 
    if (hi - lo > 2*enough) then
      yl,yr = num(), num()
      for i=lo,hi do numInc(yr, rows[i][goal]) end
      besty = yr.sd
      mu    = yr.mu
      for i=lo,hi do
        y = rows[i][goal]
        numInc(yl, y); numDec(yr, y) 
        if yl.n >= enough and yr.n >= enough then
          x1= rows[i  ][c]
          x2= rows[i+1][c]
          if x2 > x1 + Lean.super.epsilon then
            tmpy = numXpect(yl,yr) * Lean.super.margin
            if tmpy < besty then
              cut,besty = i, tmpy end end end end end
    return cut,mu
  end

  local function cuts(c,lo,hi,pre,       cut,txt,s,mu)
    txt = pre..rows[lo][c]..".."..rows[hi][c]
    cut,mu = argmin(c,lo,hi)
    if cut then
      fyi(txt)
      cuts(c,lo,   cut, pre.."|.. ")
      cuts(c,cut+1, hi, pre.."|.. ")
    else
      s = band(c,lo,hi)
      for r=lo,hi do
        sum = sum + rows[r][c]
        rows[r][c]=s end 
      fyi(txt.." ==> "..precent(sum/(hi - lo+10^-64)))
      end
  end

  function stop(c,t)
    for i=#t,1,-1 do if t[i][c] ~= "?" then return i end end
    return 0
  end

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      ksort(c,rows) -- sorts the rows on column `c`.
      most = stop(c,rows)
      fyi("\n-- ".. data.name[c] .. " ----------")
      cuts(c,1,most,"|.. ") end end
  print(gsub( cat(data.name,", "), 
              "%$","")) -- dump dollars since no more nums
  dump(rows)
end

-- Main function, if this is called top-level.

return {main=function() return super(rows()) end}
