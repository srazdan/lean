-- to be run from tests as
--
--       luajit ../src/tests.lua *.lua
--
--
--

for _,f in pairs(arg) do
  dofile(f) 
end
