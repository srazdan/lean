-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"
require "sample"
require "stats"
require "xtiles"


before, mu     =  0, all.mu
  for i,l,r in leftRight(parts,epsilon):
    if big(l.n) and big(r.n):
      n   = all.n * 1.0
      now = l.n/n*(mu- l.mu)**2 + r.n/n*(mu- r.mu)**2
      if now > before:
        before,cut,left,right = now,i,l,r
  return cut,left,right


function sk(samples)
  samples = sorted(samples, sampleLt)

  local function add(n,i)
    for _,x in paris(samples[i]) do numInc(n,x) end end
  local function dec(n,i)
    for _,x in paris(samples[i]) do numDec(n,x) end end
  local function muXpect(all,l,r,   n)  
    return l.n/all.n * (all.mu - l.mu)^2 + 
           r.n/all.n * (all.mu - r.mu)^2 end

  local function argmax(c,lo,hi,     all,l,r,cut,best,tmp)
    all, l, r = num(), num(), num()
    for i=lo,hi do add(r,i); add(all,i) end
    best = 0
    for i=lo,hi-1 do
      add(l, i)
      dec(r, i)
      tmp = muXpect(all,l,r) * Lean.unsuper.margin
      if tmp > best then
        cut,best = i, tmp end end 
    return cut
  end

  local function cuts(c,lo,hi,rank, pre,       cut,txt,b)
    txt = pre..samples[c].mu..".."..samples[c].mu)
    cut = argmax(c,lo,hi)
    if cut then
      fyi(txt)
      rank = cuts(c,lo,    cut, rank, pre.."|.. ")+1
      rank = cuts(c,cut+1, hi,  rank, pre.."|.. ")
    else
      fyi(txt.." ("..b..")")
      for r=lo,hi do
        samples[c] = rank end end
    return rank
  end

  for _,c  in pairs(data.indeps) do
    if data.nums[c] then
      if c==3 then
        ksort(c,rows)
        most = stop(c,rows)
        fyi("\n-- ".. data.name[c] .. most .. "----------")
        cuts(c,1,most,1, "|.. ") end end end
  print(gsub( cat(data.name,", "), "%$","")) 
  dump(rows)
end

return {main=function() return unsuper(rows()) end}
