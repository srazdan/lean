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

-- Working memory is the data structure `t`:
--
-- - `t.n` is  number of rows (excluding the header on row 1)
-- - `t.header` is the  first row of data file
-- -  `t.klasses[x]` is number of rows of class x
-- -  `t.h` is the  number of classes
-- -  `t.attrs[col]`  is number of unique symbols in a column
-- - `f[klass][col][val]` = frequency of val in col of klass
-- 

function nb(file,      t,stream, seen)
  t = {n=-1,  header={}, klasses={}, h=0, attr={}, f={}}
  seen = {} -- esoterica. used to track unique symbols per column
 
 -- Some Lua esoterica here. Nested tables are initialized as a side effect
-- of traversing subtable of `t.f[klass][col][val]`. Also, at some points,
-- we also recognize that we have a never-before-seen class or never-before-seen-val-in-col.
-- At those points we update `t.h` (number of klasses) and `t.attr` (number of unique symbols
-- per column).

  function freq(t,klass,col,val,inc,    tk,tkc,tkcv,tcv,tc)  
    tc = seen[col]
    if not tc then tc={} ; seen[col] = tc end
    tcv = tc[val]
    if not tcv then   
      tc[val] = 1  
      t.attr[col] = (t.attr[col] or 0) + inc 
    end 
    tk = t.f[klass]
    if not tk then t.h = t.h + inc; tk={}; t.f[klass] = tk end
    tkc = tk[col]
    if not tkc then tkc={}; tk[col] = tkc end
    tkcv = tkc[val];
    if not tkcv then tkc[val]=1 else tkc[val]=tkc[val]+inc 
    end
    return tkc[val] end

-- Training is simple: just update the `t.f[klass][col][val]` counts. 

  function train(t, cells, klass)
    t.klasses[klass] = (t.klasses[klass] or 0) + 1
    for col,val in pairs(cells) do
      if val ~= "?" then
        freq(t, klass, col, val, 1) end end end

-- Classification is simple: for each `klass` do, ask how much
-- it _likes_ some symbol in a column. Return the `klass` that likes
-- it the most.

  function classify(t,cells,         out,like, tmp)
    like = -100000 
    for klass,_ in pairs(t.f) do
      tmp = math.log((t.klasses[klass] or 0) /t.n ) 
      for col,val in pairs(cells) do
        if col ~= #cells then
          if val ~= "?" then
            tmp = tmp + math.log((freq(t,klass,col,val,0) + 1)/
  	          (t.klasses[klass] + t.attr[col])) end end end
      if tmp > like then
        like,out = tmp,klass end end
    return out,like end

-- Some low-level regualr expression stuff.

  function cols(str,   t) -- csv string to cells
    t, str = {}, str:gsub("[\n\t\r ]*","")
    for word in string.gmatch(str, '([^,]+)') do t[ #t+1 ] = word end
    return t end

-- Main function. `train` on each row. If we've seen enough data (say, 20 rows)
-- then before we train, we try to classifiy.

  function main(stream,       str,cells,klass,guess,like)
    str = io.read()
    while str do
      cells = cols(str)
      str   = io.read()
      t.n   = t.n + 1
      if t.n==0
        then t.header = cells
        else klass = cells[ #cells ]
             if t.n > 20 then 
               guess,like = classify(t, cells) 
               print(klass, guess,like) end
  	         train(t, cells, klass) end end 
    io.close(stream) end

-- This code reads from a file or standard input.

  main( file and io.input(file) or io.input())
end

return {main = nb }
