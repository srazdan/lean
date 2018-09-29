-- to be run from tests as
--
--       luajit ../src/tests.lua *.lua
--
--
--
package.path = '../src/?.lua;' .. package.path
require "config"
require "ok"

local t,f
for n,f in pairs(arg) do if n > 1 then 
	dofile(f) 
        print(">>>>>",Lean.ok.tries, Lean.ok.fails)
end end
print(okReport() == 100 and 0 or 1)
