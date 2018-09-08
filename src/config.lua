-- vim: ts=2 sw=2 sts=2 expandtab:cindent:formatoptions+=cro 
---------~---------~---------~---------~---------~---------~


Lean = {
       cohen    = 0.2,
       distance = {k=5, p=2, kernel="triangular", samples=64},
       dom      = {samples=100}, 
       domtree  = {enough=0.5},
       enough   = 100,
       fft      = {min=4},
       margin   = 1.02,
       num      = {p=2},
       ok       = {tries = 0, fails  =0},
       random   = {seed = 10013},
       sample   = {max=128}, 
       super    = {enough=0.5, margin=1.05},
       unsuper  = {enough=0.5, margin=1.05},
}
