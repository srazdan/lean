-- vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab
--------- --------- --------- --------- --------- --------- 
require "lib"

function rogues(    ignore,match)
  ignore = {
           jit=true, utf8=true, math=true, package=true, table=true, 
           coroutine=true, bit=true, os=true, io=true, 
           bit32=true, string=true, arg=true, debug=true, 
           _VERSION=true, _G=true }
  for k,v in pairs( _G ) do
    if type(v) ~= "function" and not ignore[k] then
       if k:match("^[^A-Z]") then
         print("-- warning, rogue local ["..k.."]") 
  end end end 
end 

function off(t) return t end

function ok(t,  n,score)
  s=function() return math.floor(0.5 + 100*(1- 
                        ((The.ok.tries-The.ok.fails)/
                        The.ok.tries))) end
  for x,f in pairs(t) do
    The.ok.tries = The.ok.tries + 1
    print("-- Test #" .. The.ok.tries .. 
          " (oops=".. s() .."%). Checking ".. x .."... ")
    local passed,err = pcall(f)
    if not passed then
      The.ok.fails = The.ok.fails + 1
      print("-- E> Failure " .. The.ok.fails .. " of " 
            .. The.ok.tries ..": ".. err) end end
  rogues()
end
