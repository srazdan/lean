-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
---------~---------~---------~---------~---------~---------~


function Lean0() return  {
  cohen    = 0.2,
  distance = {k=1, p=2, kernel="first", samples=64},
  dom      = {samples=100}, 
  domtree  = {enough=0.5},
  enough   = 100,
  fft      = {min=4},
  margin   = 1.02,
  num      = {p=2},
  ok       = {tries = 0, fails  =0},
  random   = {seed = 10013},
  sample   = {max=512}, 
  sk       = {conf = 95}, 
  stats    = {conf = 95,
              bootstraps = 512,
              cf = ({0.147,0.33,0.474})[1]}, 
  super    = {enough=0.5, margin=1.05},
  tiles    = {width = 50,
              chops = {{0.1,"-"},
                        {0.3," "},
                        {0.5," "},
                        {0.7,"-"},
                        {0.9," "}},
               bar  = "|",
               star = "*",
               num  = "%5.3f",
               sym  = "%20s"}, 
  unsuper  = {enough=0.5, margin=1.05},
} end

Lean = Lean0()

return Lean, Lean0
