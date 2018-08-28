-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path 
require "lib"
require "ok"
require "sym"

ok  { baseSym=function(  s)
	s=syms{ 'y','y','y','y','y','y','y','y','y',
	        'n','n','n','n','n'}
	assert( close( symEnt(s),  0.9403) )
	print(symEnt(s))
end }

