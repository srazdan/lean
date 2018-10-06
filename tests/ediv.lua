-- vim: filetype=lua ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro  
--------- --------- --------- --------- --------- ---------  

package.path = '../src/?.lua;' .. package.path 
require "lib"

ok { ediv = function()
       local function k(   r)
         r=rand()
         if     r > 0.7 then return {r,"a"}
         elseif r > 0.4 then return {r,"b"}  
         else                return {r,"c"}
         end
       end
       data = header({"$x","!y"})
       for i=1,1000 do row(data, r()) end
       ediv(data)
end}

-- ## Main 
-- If called as top-level file.

return {main = function() xxx() end}
