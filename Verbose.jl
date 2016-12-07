module Verbose

import Base: esc
export @setVerboseLevel, @verbose

macro setVerboseLevel(lvl)
  esc(:(verboseLevel = $lvl))
end

macro verbose(lvl, exp)
  if lvl < Main.verboseLevel
    esc(:($exp))
  end
end

end  # module
