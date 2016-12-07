include("Verbose.jl")
importall Verbose

@setVerboseLevel 2 
@verbose 0 println(0)
@verbose 1 println(1)
@verbose 2 println(2)
@verbose 3 println(3)
@verbose 4 println(4)
@verbose 5 println(5)
