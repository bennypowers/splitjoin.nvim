local list = { 1, 2, 3 }

local table = { a = 'a', b = 'b', c = 'c' }

local mixed = { 1, 2, 3, a = 'a', b = 'b', c = 'c' }

local this = { 1, 2, 3, a = 'a', b = { d = 'd', e = 'e' }, c = { 4, 5, 6 } }

local a, b, c = d

a, b, c = d

f(a, b, c, g(d, e))

local function theother(a, b, c)
  a, b, c = otherwise(a, b, c)
end

local function that(a, b, c)
  local a, b, c = thefirst(a, b, c)
  f(a, b, c, g(d, e))
end

if this then that() end

if this and that then theother() end

if this then theother() else thefirst() end

if this then that() elseif theother then thefirst() else otherwise() end

local function thefirst()
  if this then that() elseif theother then thefirst() else otherwise() end
end

local f = function() end
local function g() return end

