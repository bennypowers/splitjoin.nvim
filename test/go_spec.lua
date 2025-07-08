local helpers = require'test.helpers'

describe("go", function ()
  describe("struct", function ()
local joined = [[
type User struct { Name string; Age int; Email string }
]]

local split = [[
type User struct {
  Name string,
  Age int,
  Email string,
}
]]

helpers.make_suite(
  'go',
  'splits and joins struct fields',
  joined,
  split,
  '{'
)

  end)
  describe("params and return", function ()

local joined = [[
func Foo(a int, b string) (int, error) {}
]]

local split = [[
func Foo(
  a int,
  b string,
) (
  int,
  error,
) {}
]]

helpers.make_suite(
  'go',
  'splits and joins function params and return types',
  joined,
  split,
  'Foo'
)
end)
  describe("args", function ()
local joined = [[
Foo(a, b, c)
]]

local split = [[
Foo(
  a,
  b,
  c,
)
]]

helpers.make_suite(
  'go',
  'splits and joins function arguments',
  joined,
  split,
  'Foo'
)
  end)
end)


