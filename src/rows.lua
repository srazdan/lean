--vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

require "num"
-- ## Example 
-- This code handles tables of data, like the following.
--
--     outlook, $temp, <humid, wind, !play
--     over,	64,	65,	TRUE,	yes
--     over,	64,	65,	TRUE,	yes
--     over,	72,	90,	TRUE,	yes
--     over,	83,	86,	FALSE,	yes
--     sunny,	69,	70,	FALSE,	yes
--     sunny,	69,	70,	FALSE,	yes
--     rainy,	65,	70,	TRUE,	no
--     sunny,	75,	70,	TRUE,	yes
--     sunny,	75,	70,	TRUE,	yes
--     sunny,	85,	85,	FALSE,	no
--     rainy,	71,	91,	TRUE,	no
--     rainy,	70,	96,	FALSE,	yes
--     rainy,	70,	96,	FALSE,	yes
--
-- Tables can be created two ways
--
-- - From disk data;
-- - From ram data;
--
-- In both cases, the first row is handled by the `header`
-- function and the other rows are handled by the `rows`
-- functions, shown below.
--
-- ## Inside  a `data`
--
-- A `data` object holds lists of various things, including `rows` of the actual data
-- plus some meta knowledge. 
--
-- - E.g. `name[c]` is the name of column `c`. 
-- - Some columns are goals we want to achienge and each of
--   those has a weight `w` (and `w[c]s==-1` means _minimize_
--   and w[c]==1 means _maximize_).
-- - `Data` may have one (and only) one `class` column.

function data()
  return {w={}, nums={}, class=nil, rows={}, name= {}, _use={}} 
end

-- Columns can be `indep`endent or `dep`endent and the goal
-- of learning is often to find what parts of the former
-- predict for the latter.

function indep(t,c) return not t.w[c] and t.class ~= c end
function dep(t,c)   return not indep(t,c) end

-- To create a table from ram data, start with, e.g.
--
--     names2data({'outlook', '$temp', '<humid', 'wind', '!play'})

function names2data(name) return header(data(), name) end

-- Note the special symbols in a header:
--
-- - '<' is a dependent goal to be maximized (it is also numeric)
-- - '>' is a dependent goal to be minimized (it is also numeric)
-- - '$' is an independent  numeric colum;
-- - '!' is a class column (and is not numeric).

function header(t,cells,     c,w)
  for c0,x in pairs(cells) do
    if not x:match("%?")  then
      c = #t._use+1
      t._use[c] = c0
      t.name[c] = x
      if x:match("[<>%$]") then t.nums[c] = num() end 
      if x:match("<")      then t.w[c]  = -1 end
      if x:match(">")      then t.w[c]  =  1 end 
      if x:match("!")      then t.class =  c end end end
  return t
end

-- For example, the above example call to `names2data` returns

function row(t,cells,     x,r)
  r= #t.rows+1
  t.rows[r] = {}
  for c,c0 in pairs(t._use) do
    x = cells[c0]
    if t.nums[c] then 
      if x ~= "?" then
	x = tonumber(x)
        numInc(t.nums[c], x) end end
    t.rows[r][c] = x  end
  return t
end  

function rows1(stream, t,f0,f,   first,line,cells)
  first,line = true,io.read()
  while line do
    line= line:gsub("[\t\r ]*","")
              :gsub("#.*","")
    cells = split(line)
    line = io.read()
    if #cells > 0 then
      if first then f0(t,cells) else f(t,cells) end end
      first = false
  end 
  io.close(stream)
  return t
end

function rows(file,t,f0,f,      stream,txt,cells,r,line)
  return rows1( file and io.input(file) or io.input(),
                t  or data(), f0 or header, f or row) end 

