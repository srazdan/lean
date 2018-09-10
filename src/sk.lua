-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"
require "sample"
require "stats"
require "xtiles"

function sk(samples,  epsilon)
  local function inc(n,i,f)
    f = f or numInc
    for _,x in pairs(samples[i].some) do f(n,x) end end

  local function prediction(all,l,r)  
    return l.n/all.n * (all.mu - l.mu)^2 + 
           r.n/all.n * (all.mu - r.mu)^2 end

  local function argmax(lo,hi,       all,l,r,cut,best,tmp)
    all, l, r = num(), num(), num()
    for i=lo,hi do inc(r,i); inc(all,i) end
    epsilon = epsilon or Lean.sk.cohen * all.sd
    best = 0
    for i=lo,hi-1 do
      inc(l, i)
      inc(r, i, numDec)
      if l.mu + epsilon < r.mu then
        tmp = prediction(all,l,r) * Lean.unsuper.margin
        if tmp > best then
          if different(l._some, r._some) then
            cut,best = i, tmp end end end end
    return cut end

  local function cuts(lo,hi,rank, pre,            cut,txt)
    txt= pre .. nth(samples[lo],.5) .. nth(samples[hi],.5)
    cut= argmax(lo,hi)
    if cut then
      fyi(txt)
      rank = cuts(lo,    cut, rank, pre.."|.. ") + 1
      rank = cuts(cut+1, hi,  rank, pre.."|.. ")
    else
      fyi(txt.." ("..rank..")")
      for i=lo,hi do
        samples[i].rank = rank end end
    return rank end

  samples = sorted(samples, sampleLt)
  cuts(1, #samples,1,"|.. ")
end
