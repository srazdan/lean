-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

function nb(file,       t,stream,str,cells,klass)
  t = {n=-1, header={}, klasses={},  h=0, f={}}
 
  function cols(str,   t) -- csv string to cells
    t, str = {}, str:gsub("[\n\t\r ]*","")
    for word in string.gmatch(str, '([^,]+)') do
      t[ #t+1 ] = tonumber(word) or word
    end
    return t end

  function freq(t,x,y,z,inc,    tx,txy,txyz)  -- change counts
    tx = t[x]
    if not tx then t.h = t.h + inc; tx={}; t[x] = tx end
    txy = tx[y]
    if not txy then txy={}; tx[y] = txy end
    txyz = txy[z];
    if not txyz 
      then txy[z] = 1 
	   t.attr[y] = (t.attr[y] or 0) + inc 
      else txy[z]= txyz+inc 
    end
    return txy[z] end
  
  function get(t,x,y,z) return freq(t,x,y,z,0) end
  function inc(t,x,y,z) return freq(t,x,y,z,1) end

  function train(t, cells, klass)
    t.klasses[klass] = (t.klasses[klass] or 0) + 1
    for col,val in pairs(cells) do
      if val ~= "?" then
        inc(t.f, klass, col, val, 1) end end end
  
  function classify(t,         like, tmp)
    like = -100000 
    for klass,_ in pairs(t) do
      tmp = math.log((t.klasses[klass] or 0) /t.n ) 
      for col,val in pairs(cells) do
        if val ~= "?" then
          tmp = tmp + math.log((get(klass,col,val) + 1)/
  	        (t.klasses[klass] + t.attr[col])) end end
      if tmp > like then
        like,out = tmp,klass end end
    return out end
  
  stream = file and io.input(file) or io.input()
  str = io.read()
  while str do
    cells = cols(str)
    str   = io.read()
    t.n   = t.n + 1
    if t.n==0
      then t.header = cells
      else klass = cells[ #cells ]
           if t.n > 20 then print(klass, classify(t, cells)) end
	   train(t, cells, klass)
  end end
  io.close(stream)
  return t
end

return {main = nb }
