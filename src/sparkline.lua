-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

do
  local u = '▁▂▃▄▅▆▇█' -- unicode
  local a = {}         -- ascii
  for i,c in utf8.codes(u) do a[ #a+1 ] = utf8.char(c)  end

  function sparkline(nums,    lo,hi,s)
    lo,hi=10^32, -10^32
    for _,x in pairs(nums) do
      if x > hi then hi = x end
      if x < lo then lo = x end end
    s=''
    for _,x in pairs(nums) do
       x = 8*(x-lo)/(hi - lo + 10^-32)
       x = min(7, math.floor(x)) + 1
       s = s .. a[x] end
    return s 
  end 
end

function sparklineDemo(   n)
  n={}
  math.randomseed(arg[1] or 1)
  for i=1,80 do n[ #n+1] = math.random() end
  print(sparkline(n))
end

sparklineDemo()
