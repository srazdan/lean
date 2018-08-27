-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

require "lib"

function abcd(db,rx) 
  return {known ={}, a={},b={},c={},d={},
          rx=rx or "rx", db=db or "db", yes=0, no=0}
end

-----------------------------------------------------------
function abcdHas(t,x)
  if not t.known[x] then
    t.a[x] = 0
    t.b[x] = 0
    t.c[x] = 0
    t.d[x] = 0
    t.known[x] = 0
  end
  t.known[x] = t.known[x] + 1
  if t.known[x] == 1 then
    t.a[x] = t.yes + t.no end
end 

-----------------------------------------------------------
function abcdInc(t,want, got)
  abcdHas(t,want)
  abcdHas(t,got)
  if   want == got 
  then t.yes = t.yes + 1
  else t.no  = t.no  + 1 
  end 
  for x,_ in pairs(t.known) do
    if want == x then
      if   want == got then
           t.d[x] = t.d[x] + 1
      else t.b[x] = t.b[x] + 1 end 
    else
      if   got == x then
           t.c[x] = t.c[x] + 1
      else t.a[x] = t.a[x] + 1 end end end 
end

-----------------------------------------------------------
function abcdReport(t,   out,pd,pf,pn,prec,g,f,acc,a,b,c,d)
  p = function(x) return 100*x end
  out = {}
  for x,_ in pairs(t.known) do
    pd,pf,pn,prec,g,f,acc = 0,0,0,0,0,0,0
    a,b,c,d = t.a[x], t.b[x], t.c[x], t.d[x]
    if b+d > 0     then pd   = d     / (b+d) end
    if a+c > 0     then pf   = c     / (a+c) end
    if a+c > 0     then pn   = (b+d) / (a+c) end
    if c+d > 0     then prec = d     / (c+d) end
    if 1-pf+pd > 0 then g=2*(1-pf) * pd / (1-pf+pd) end
    if prec+pd > 0 then f=2*prec*pd / (prec + pd)   end
    if t.yes + t.no > 0 then 
       acc  = t.yes / (t.yes + t.no) end
    out[x] = {
       db=t.db, rx=t.rx, num=a+b+c+d, a=a, b=b, 
       c=c, d=d, acc=p(acc),  prec=p(prec), pd=p(pd),  
       pf=p(pf), f=p(f)}
  end
  return out
end

-----------------------------------------------------------
function abcdShow(t0, t,  head,t,j,new)
  local head={"db", "rx", "num", "a", "b", 
       "c", "d", "acc",  "prec", "pd",  
       "pf", "f"}
  t={}
  t[1] = head
  t[1][ #head+1 ] = "class"
  for class,row in pairs(abcdReport(t0)) do
     new={}
     for k,f in pairs(head) do
       j=k
       new[k] = row[f] end 
       new[ #new+1 ] = class
     t[ #t+1 ] = new
  end
  cols( t , "%5.0f" ) 
end
