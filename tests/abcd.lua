#!/usr/bin/env lua
-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- ---------~

package.path = '../src/?.lua;' .. package.path
require "lib"
require "ok"
require "abcd"


ok { abcd = function()
      
      end}

-- === Confusion Matrix ===
--  a b c   <-- classified as
--  6 0 0 | a = yes
--  0 2 0 | b = no
--  0 1 5 | c = maybe

ok { abcd = function()
  local x = abcd("synthetic","raw")
  for _ = 1,6 do abcdInc(x,"yes",   "yes")   end
  for _ = 1,2 do abcdInc(x,"no",    "no")    end
  for _ = 1,5 do abcdInc(x,"maybe", "maybe") end
  abcdInc(x,"maybe","no")
  abcdShow(x)
end }
--
-- === Detailed Accuracy By Class ===
--                TP Rate   FP Rate   Precision   Recall  F-Measure   ROC Area  Class
--                  1         0          1         1         1          1        yes
--                  1         0.083      0.667     1         0.8        0.938    no
--                  0.833     0          1         0.833     0.909      0.875    maybe
-- Weighted Avg.    0.929     0.012      0.952     0.929     0.932      0.938
--
