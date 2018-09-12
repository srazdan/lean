-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

[[--
local function memo(samples,here,stop,_memo,    b4,inc)
  if stop > here then inc=1 else inc=-1 end
  if here ~= stop then
     b4=  lst.copy( memo(samples,here+inc, stop, _memo)) end
  _memo[here] = updates(samples[here]._all,  b4)
  return _memo[here] end
---------------------------------------------
-- Seek a split that maximizes the expected value
-- of the square of the difference in means before
-- and after the split. At that point, if the two
-- splits are not statistically the same, then
-- recurse into each part of the split.

return function (samples,epsilon,same)
  epsilon = epsilon or the.sample.epsilon
    local function split(lo,hi,all,rank,lvl)
      local best,lmemo,rmemo = 0,{},{}
      memo(samples,hi,lo, lmemo) -- summarize i+1 using i
      memo(samples,lo,hi, rmemo) -- summarize i using i+1
      local cut, lbest, rbest
      for j=lo,hi-1 do -- step1: look for the best cut
        local l = lmemo[j]
        local r = rmemo[j+1]
        if mid(l)*the.sample.epsilon < mid(r) then
          if not same(l,r) then
            local tmp= l.n/all.n*(l.mu - all.mu)^2 +
                       r.n/all.n*(r.mu - all.mu)^2
            if tmp > best then

--]]

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

  local function argmax(lo,hi,rank,
                        all,l,r,cut,best,tmp)
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
          --print(2)
          --o(">>>",#all._some)
          --if different(l._some, r._some) then
            --print(3)
            cut,best = i, tmp end end end
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
