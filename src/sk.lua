-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"
require "sample"
require "stats"
require "xtiles"
require "meta"

function sk(samples,  epsilon)
  local function inc(n,i,f)
    n = n or num()
    f = f or numInc
    for _,x in pairs(samples[i].some) do f(n,x) end 
    return n
  end

  local function accumulate(i, j, k, t,      b4)
    if i ~= j then b4 = accumulate(i+k, j, k, t) end
    t[i] = inc( deepCopy(b4), i)
    return t[i] end

  local function improvement(all,l,r)  
    return l.n/all.n * (all.mu - l.mu)^2 + 
           r.n/all.n * (all.mu - r.mu)^2 end

  local function stasticallyDifferent(l,r)
    --return true 
    return different(sampleSorted(l._some), sampleSorted(r._some)) 
  end

  local function argmax(lo,hi,rank, 
                        all,l,ls,r,rs,cut,best,tmp)
      rs,ls ={},{} 
      accumulate(lo, hi,  1, rs)
      accumulate(hi, lo, -1, ls)
      epsilon = epsilon or Lean.sk.cohen * ls[hi].sd
      best = 0
      for i=lo,hi-1 do
        l = ls[i]
        r = rs[i+1]
        if nth(l._some, .5)  + epsilon < nth(r._some, .5) then
          tmp = improvement(ls[hi],l,r) * Lean.unsuper.margin
          if tmp > best then
            if stasticallyDifferent(l,r) then
              cut,best = i, tmp end end end end
    return cut end

  local function cuts(lo,hi,rank, pre,            cut,txt)
    txt= pre..nth(samples[lo],.5)..':'..nth(samples[hi],.5)
    cut= argmax(lo,hi,rank)
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
  cuts(1, #samples,1,"")
  return samples
end
