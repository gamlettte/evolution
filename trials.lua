local lanes = require "lanes".configure()

local function calculate(a,b,c)
  if not a then
    error "sample error; propagated to main lane when reading results"
  end
  return a+b+c
end

local h1= lanes.gen("base", calculate)(1,2,3)
local h2= lanes.gen("base", calculate)(10,20,30)
local h3= lanes.gen("base", calculate)(100,200,300)

print( h1[1], h2[1], h3[1] )     -- pends for the results, or propagates error
