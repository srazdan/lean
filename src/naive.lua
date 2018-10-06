#!/usr/bin/env luajit
-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

require "lib"

function nb(file,     t)
  t = {n=-1,  header={}, klasses={}, seen={}, attr={}, f={}}
 
  local function train(row, k)
    t.klasses[k] = (t.klasses[k] or 0) + 1
    for c,v in pairs(row) do
      if v ~= "?" then
        t.f[k][c][v] = (t.f[k][c][v] or 0) + 1 
        if not t.seen[c][v]  then
          t.seen[c][v]  = true       
          t.attr[c] = t.attr[c] + 1 end end end end

  local function classify(row,    out,like, prior, evidence,post)
    like  = -100000, {} 
    for k,_ in pairs(t.f) do
      prior = (t.klasses[k] or 0) /t.n  
      post  = log(prior)
      for c,v in pairs(row) do
        if c ~= #row then
          if v ~= "?" then
            evidence = ((t.f[k][c][v] or 0) + 1) / 
                       (t.klasses[k] + t.attr[c]) 
            post = post + log(evidence) end end end  
      if post > like then
        like,out = post,k end end
    return out,like end

  local function headers(row) 
    t.header = row 
    for c,_ in pairs(row) do t.seen[c], t.attr[c] = {},0 end end

  local function data(row,k,       klass)
    if not t.f[k] then
      t.f[k], t.klasses[k] = {}, 0 
      for c,_ in pairs(t.header) do t.f[k][c] = {} end end 
    if t.n > 20 then 
      print(k,  classify(row) ) end
    train(row, k ) end

  first=true
  for cells in csv(file) do
    if first 
      then first=false; headers(cells) 
      else data(cells, cells[#cells]) end end
  return t
end

return {main=nb}