-- to be run from tests as
--
--       luajit ../src/tests.lua *.lua
--
--
--
package.path = '../src/?.lua;' .. package.path

for i,f in pairs(arg) do if i > 1 then 
  dofile(f) 
end end
os.exit(Lean.ok.fails < 2 and 0 or 1)
