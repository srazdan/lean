-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro   
--------- --------- --------- --------- --------- --------- 

require "lib"

-- ## Inside a `sample`
--
-- Samples keep up to `max` items in a list
-- called `some`.
--

function sample(max) 
  return {max=max or The.sample.max, 
          n=0, sorted=false, some={}}
end

-- Note that the larger the `max`, the more
-- accurate the sample. For example, here's
-- what happens when `max` is 16 to 1024
-- and 10,000 times, we add in a random number
-- 0..1 (which should have a mean of 0.5)
--
--        16        0.29368748203557
--        32        0.58862982717745
--        64        0.49891762831198
--        128       0.43968772070468
--        256       0.51844127640056
--        512       0.50585840060648
--        1024      0.51028261217767
--

-- Obviously, we can add up to `max` items, very simply.
-- But after that, we have to overwrite something
-- to fit in the new thing (which we do at probablity
-- `size(some)/n` items) where `n` is number of
-- times we've tried to add something here.

function sampleInc(t,x,      now)
  t.n = t.n + 1
  now = #t.some
  if now < t.max then 
    t.sorted = false
    t.some[ #t.some+1 ] = x
  elseif rand() < now/t.n then
    t.sorted = false
    t.some[ math.floor(0.5+ rand()*now) ] = x end
  return x
end

-- Never resort if we are already sorted.

function sampleSorted(t)
  if not t.sorted then t.sorted=true; table.sort(t.some) end
  return t.some
end

-- But once they are sorted, we can access the `nth`
-- percentile item.

function nth(t,n,    s)
  s = sampleSorted(t)
  return s[ min(#s, max(1, math.floor(0.5 + #s*n))) ]
end
