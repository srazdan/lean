-- to be run from tests as
--
--       luajit ../src/tests.lua *.lua
--
--
--
package.path = '../src/?.lua;' .. package.path

for i,f in pairs(arg) do if i > 1 then 
  dofile(f) 
  print("\n\n\n###### "..f.." ################")
  print("#\n#\n#\tpass= "..Lean.ok.tries.. " fails= " .. Lean.ok.fails)
  print("#\n#\n#################################")
end end
os.exit(Lean.ok.fails < 2 and 0 or 1)
