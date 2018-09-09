-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"
require "num"
require "sample"
---------------------------------
-- Simple utils

local function nth(t,n) return t._all[  math.floor(#t._all*n) ] end
local function mid(t)   return nth(t,0.5) end
local function iqr(t)   return nth(t,0.75) - nth(t,0.25) end
---------------------------------
-- Here's a simple counter, used to track  `mu` and `all`.

local function create() return {
  _all={}, sum=0,n=0, mu=0} end

-- Here how to update a counter with one value `x`.
local function update(i,x) 
  i._all[#i._all+1]=x
  i.sum = i.sum + x
  i.n   = i.n + 1 
  i.mu  = i.sum/i.n end

-- Here how to update a counter with many values from `t`.
local function updates(t, counter)
  counter = counter or create()
  for j=1,#t do 
    update(counter,t[j]) end 
  return counter end
---------------------------------------------
-- This code is always counting left and right within
-- the list of samples. To save time, memo all those 
-- "peeks".

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
              cut   = j
              best  = tmp
              lbest = lst.copy(l)
              rbest = lst.copy(r) end end end end
      if cut then -- step2a: use the cut (if you found it)
        rank = split(lo,   cut, lbest, rank, lvl+1) + 1
        rank = split(cut+1, hi, rbest, rank, lvl+1)
      else -- step2b: otherwise, all samples get same rank
        for j=lo,hi do
          samples[j].rank = rank end end
      return rank 
    end 
  table.sort(samples, function (x,y) return 
             mid(x) < mid(y) end)
  split(1,#samples, memo(samples,1,#samples,{}),1,0)  
  return samples end
end

 
function cliffsDelta(lst1,lst2, threshold)
  threshold = threshold or Lean.lib.cf
  local function bsearch(t,val,f)
    f = f or function (t,x) return t[x] end
    local lo,hi=1,#t
    while lo <= hi do
      local mid = (lo+hi)/2
      mid = math.floor(mid)
      if f(t,mid) >= val then
        hi = mid - 1
      else
        lo = mid + 1 end end
    return math.min(lo,#t)  end
  
  local lt,gt,max=0,0,#lst2
  for _,one in pairs(lst1) do
    local pos0 = bsearch(lst2,one)
    local pos = pos0
    while pos < max and lst2[pos] == lst2[pos+1] do pos = pos + 1 end
    gt = gt + max - pos
    local pos = pos0
    while pos > 1   and lst2[pos] == lst2[pos-1] do pos = pos - 1 end
    lt = lt + pos end
  return math.abs(gt - lt) / (#lst1 * #lst2) > threshold end

function clifdsDeltaSample(s1,s2)
  return cliffsDelta( sampleSorted(s1), sampleSorted(s2) )
  
-------------------------------------------------------------------
-- ### Statistical significance test (non-parametric)
-- The bootstrap hypothesis test from 220 to 223 of Efron's book
-- 'An introduction to the boostrap'.

local function bootstrap(y0,z0)
     local function sampleWithReplacement(lst)
       local function n()   return math.floor(R.r() * #lst) + 1 end
       local function one() return lst[n()] end
       local out={}
       for i=1,#lst do out[i] = one() end
       return out
     end
     local function delta(y,z)
       return (y.mu - z.mu) / (10^-64 + (y.sd/y.n + z.sd/z.n)^0.5)
     end
     local function updates(i,lst)
       for j=1,#lst do
         local x = lst[j]
         i.all[#i.all + 1] = x
         i.n  = i.n + 1
         local delta = x - i.mu
         i.mu = i.mu + delta / i.n
         i.m2 = i.m2 + delta * (x - i.mu)
         if i.n > 1 then
           i.sd = (i.m2 / (i.n - 1))^0.5 end end
       return i
     end
     local function create(lst)
       return updates({sum=0, n=0,mu=0, all={},m2=0,sd=0}, lst)
     end
     local function add(i,j)
       return updates( LST.copy(i), j)
     end
  local y, z = create(y0), create(z0)
  local x    = add(y,z)
  local tobs = delta(y,z)
  local yhat, zhat = {}, {}
  for i=1,#y.all do yhat[i] = y.all[i] - y.mu + x.mu end
  for i=1,#z.all do zhat[i] = z.all[i] - z.mu + x.mu end
  local bigger = 0
  for _ = 1,the.sample.b do
    if delta(create(sampleWithReplacement(yhat)),
             create(sampleWithReplacement(zhat))) > tobs then
      bigger = bigger + 1 end end
  return bigger / the.sample.b > the.num.conf/100 end

local function same(i,j)
  return not(cliffsDelta(i,j) and bootstrap(i,j)) end
