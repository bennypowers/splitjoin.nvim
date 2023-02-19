local list = { 1, 2, 3 }

local table = { a = 'a', b = 'b', c = 'c' }

local mixed = { 1, 2, 3, a = 'a', b = 'b', c = 'c' }

local function params(a, b, c)
  a, b, c = mod(a, b, c)
end

a, b, c = d
