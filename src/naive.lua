-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

-- ## About
-- A Bayes classifier is a simple statistical-based learning scheme.
--
-- Advantages:
--
-- + Tiny memory footprint
-- + Fast training, fast learning
-- + Simplicity
-- + Often works surprisingly well
--
-- ## Example
-- 
-- _weather.symbolic.arff_:
-- 
--     outlook  temperature  humidity   windy   play
--     -------  -----------  --------   -----   ----
--     rainy    cool        normal    TRUE    no
--     rainy    mild        high      TRUE    no
--     sunny    hot         high      FALSE   no
--     sunny    hot         high      TRUE    no
--     sunny    mild        high      FALSE   no
--     overcast cool        normal    TRUE    yes
--     overcast hot         high      FALSE   yes
--     overcast hot         normal    FALSE   yes
--     overcast mild        high      TRUE    yes
--     rainy    cool        normal    FALSE   yes
--     rainy    mild        high      FALSE   yes
--     rainy    mild        normal    FALSE   yes
--     sunny    cool        normal    FALSE   yes
--     sunny    mild        normal    TRUE    yes%%
-- 
-- This data can be summarized as follows:
-- 
-- 
-- 
--                Outlook            Temperature           Humidity
--     ====================   =================   =================
--               Yes    No            Yes   No            Yes    No
--     Sunny       2     3     Hot     2     2    High      3     4
--     Overcast    4     0     Mild    4     2    Normal    6     1
--     Rainy       3     2     Cool    3     1
--               -----------         ---------            ----------
--     Sunny     2/9   3/5     Hot   2/9   2/5    High    3/9   4/5
--     Overcast  4/9   0/5     Mild  4/9   2/5    Normal  6/9   1/5
--     Rainy     3/9   2/5     Cool  3/9   1/5
-- 
--                 Windy        Play
--     =================    ========
--           Yes     No     Yes   No
--     False 6      2       9     5
--     True  3      3
--           ----------   ----------
--     False  6/9    2/5   9/14  5/14
--     True   3/9    3/5
-- 
-- So, what happens on a new day:
-- 
--     Outlook       Temp.         Humidity    Windy         Play
--     Sunny         Cool          High        True          ?%%
-- 
-- First find the likelihood of the two classes
-- 
-- + For "yes" = 2/9 * 3/9 * 3/9 * 3/9 * 9/14 = 0.0053
-- + For "no" = 3/5 * 1/5 * 4/5 * 3/5 * 5/14 = 0.0206
-- 
-- Conversion into a probability by normalization:
-- 
-- + P("yes") = 0.0053 / (0.0053 + 0.0206) = 0.205
-- + P("no") = 0.0206 / (0.0053 + 0.0206) = 0.795
-- 
-- So, we aren't playing golf today.
-- 
-- ## Bayes' rule
-- 
-- More generally, the above is just an application of Bayes' Theorem.
-- 
-- Probability of event H given evidence E:
-- 
--                   Pr[E | H ] * Pr[H]
--     Pr[H | E] =  -------------------
--                       Pr[E]
-- 
-- A _priori probability_ of H= Pr[H]
-- 
-- + Probability of event before evidence has been seen
-- 
-- A _posteriori probability_ of H= Pr[H|E]
-- 
-- + Probability of event after evidence has been seen
-- 
-- Classification learning: what's the probability of the class given an instance?
-- 
-- + Evidence E = instance
-- + Event H = class value for instance
-- 
-- Naive Bayes assumption: evidence can be split into independent parts (i.e. attributes of instance!
-- 
--                 Pr[E1 | H ]* Pr[E2 | H ] * ....  *Pr[En | H ]Pr[H ]
--     Pr[H | E] = ---------------------------------------------------
--                                    Pr[E]
-- 
-- We used this above. Here's our evidence:
-- 
--     Outlook       Temp.         Humidity    Windy         Play
--     Sunny         Cool          High        True          ?
-- 
-- Here's the probability for "yes":
-- 
--     Pr[ yes | E] = Pr[Outlook     = Sunny | yes] *
--                    Pr[Temperature = Cool  | yes] *
--                    Pr[Humidity     = High  | yes] * Pr[ yes]
--                    Pr[Windy       = True  | yes] * Pr[yes] / Pr[E]
--                  = (2/9 * 3/9 * 3/9 * 3/9)       * 9/14)   / Pr[E]
-- 
-- Return the classification with highest probability
-- 
-- ## Sample Code
-- The following code assumes discrete independent and depedent variables, and the class is the
-- last column and that data is on some csv file, the first line of which is the column names.

----------------------------------------------------
-- ### Support Code 
-- Here's a simel csv reader.
-- Read rows of comma seperated data either from standard input or from a file.
function csv(file,           n,str,row,stream)
  stream = file and io.input(file) or io.input()
  n,str  = 0, io.read()
  return function ()
    while str do
      n   = n + 1
      row = {} 
      str = str:gsub("[\n\t\r ]*","")
      for word in string.gmatch(str, '([^,]+)') do 
        row[ #row+1 ] = tonumber(word) or word end
      str   = io.read()
      return row, n, #row 
    end 
    io.close(stream) end 
end
----------------------------------------------------
-- ### Main NB stuff.

-- Working memory is the data structure `t`:
--
-- - `t.n` is  number of rows (excluding the header on row 1)
-- - `t.header` is the  first row of data file
-- -  `t.klasses[x]` is number of rows of class x
-- -  `t.attrs[col]`  is number of unique symbols in a column
-- - `f[klass][col][val]` = frequency of val in col of klass

function nb(file,      t,seen)
  t = {n=-1,  header={}, klasses={}, attr={}, f={}}
  seen = {} 
 
-- Training is simple: just update the `t.f[klass][col][val]` counts. 
-- Also, if this is the first time we've seen this value in  this
-- column, incremeent the count of unique symbols in this column.

  function train(row, k)
    t.klasses[k] = (t.klasses[k] or 0) + 1
    for c,v in pairs(row) do
      if v ~= "?" then
        t.f[k][c][v] = (t.f[k][c][v] or 0) + 1 
        if not seen[c][v]  then
          seen[c][v]  = 1       
          t.attr[c] = t.attr[c] + 1 end end end end

-- Classification is simple: for each `klass` do, ask how much
-- it _likes_ some symbol in a column. Return the `klass` that likes
-- it the most.  Using log addition not raw multiplication to avoid
-- problems with numerical precision.

  function like1(k,c,v)
    return ((t.f[k][c][v] or 0) + 1) / (t.klasses[k] + t.attr[c]) end  

  function classify(row,         out,like, tmp)
    like, likes = -100000, {} 
    for k,_ in pairs(t.f) do
      tmp = math.log((t.klasses[k] or 0) /t.n ) 
      for c,v in pairs(row) do
        if c ~= #row then
          if v ~= "?" then
            tmp = tmp + math.log( like1(k,c,v) ) end end end
      if tmp > like then
        like,out = tmp,k end end
    return out,like end

-- When we see a new class, add another nested table to `t.f`.

  function klasses(k)
    if not t.f[k] then
      t.f[k], t.klasses[k] = {}, 0 
      for c,_ in pairs(t.header) do t.f[k][c] = {} end end 
    return k end

-- When we see new headers, intialize `seen` and `t.attr`.

  function headers(row) 
    for c,_ in pairs(row) do seen[c], t.attr[c] = {},0 end
    t.header = row end 

-- When we read a new row, always train on it. Sometimes classify it.
  function data(row,k,       klass)
    klasses(k)
    if t.n > 20 then 
      print(k,  classify(row) ) end
    train(row, k ) end

  for row, nr, nf in csv(file) do
    t.n = nr
    if t.n == 1 then headers(row) else data(row, row[nf]) end end
end

return { main = nb }
