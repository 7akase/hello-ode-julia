module Debug

export @ifdef, @ifndef

macro ifdef(key :: Symbol, ex :: Expr)
  if isdefined(key)
    esc(ex)
  end
end

macro ifndef(key :: Symbol, ex :: Expr)
  if !isdefined(key)
    esc(ex)
  end
end

# ----------------------------------------------------------------------
# Support Functions
# ----------------------------------------------------------------------
function inMain(s :: Symbol) 
  parse("Main." * string(s))
end

function extractSymbols(ex :: Expr)
  filterExpr(x -> isa(x, Symbol), ex.args)
end

function filterExpr(op, xss)
  filterExpr(op, xss, [])
end

function filterExpr(op, xss, ys)
  if isempty(xss)
    return ys
  else
    for i in xss
      if op(i)
        push!(ys, i)
      end
      if isa(i, Expr)
        filterExpr(op, i.args, ys)
      end
    end
    return ys
  end
end
# ----------------------------------------------------------------------

end  # module
