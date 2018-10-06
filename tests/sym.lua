-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
--------- --------- --------- --------- --------- --------- 

package.path = '../src/?.lua;' .. package.path 
require "lib"

ok  { baseSym=function(  s)
	s=syms{ 'y','y','y','y','y','y','y','y','y',
	        'n','n','n','n','n'}
	assert( 0.94028 < ent(s) and ent(s) < 0.94029 )
	print(ent(s))
end }

ok { inc=function(        datas,data,kept,all,s,syms,kept)
  datas,kept,all = {},{},{}
  rseed(1)
  syms={"a","b","c","d","e","f","g","h","i","j","k","l"}
  for i=1,20 do
    data={}
    datas[ i ] = data
    for j=1,20 do data[j] = any(syms) end end
  s= sym()
  for i=1,20 do
    map(datas[i], function (z) sinc(s, z) end)
    kept[i] = ent(s)
  end
  for i=20,3,-1 do
    assert(ent(s) == kept[i])
    map(datas[i], function (z) sdec(s, z) end)
  end
end }



