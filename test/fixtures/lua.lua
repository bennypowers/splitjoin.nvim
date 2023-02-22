local list = { 1, 2, 3 }

local table = { a = 'a', b = 'b', c = 'c' }

local mixed = { 1, 2, 3, a = 'a', b = 'b', c = 'c' }

local function params(a, b, c)
  a, b, c = mod(a, b, c)
end

local a, b, c = d

a, b, c = d

f(a, b, c, g(d, e))

if this then that() end

if this and that then theother() end

if this then theother() elseif thefirst() end

if this then that() elseif theother then thefirst() else otherwise() end


function hi()
  if this then that() elseif theother then thefirst() else otherwise() end
end
