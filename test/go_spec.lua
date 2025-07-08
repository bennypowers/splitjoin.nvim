local helpers = require'test.helpers'
local d = require'plenary.strings'.dedent

describe("go", function()
  describe("struct", function()
    local joined = [[
type User struct { Name string; Age int; Email string }
]]

    local split = [[
type User struct {
  Name string
  Age int
  Email string
}
]]

    helpers.make_suite('go', 'splits and joins struct fields', joined, split, '{')
  end)

  describe("params", function()
    local joined = [[
func Foo(a int, b string) (int, error) {}
]]

    local split = [[
func Foo(
  a int,
  b string,
) (int, error) {}
]]

    helpers.make_suite('go', 'splits and joins function params', joined, split, 'a')
  end)

  describe("return", function()
    local joined = [[
func Foo(a int, b string) (int, error) {}
]]

    local split = [[
func Foo(a int, b string) (
  int,
  error,
) {}
]]

    helpers.make_suite('go', 'splits and joins return types', joined, split, 'error')
  end)
  describe("args", function()
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

    helpers.make_suite('go', 'splits and joins function arguments', joined, split, 'a')
  end)

  describe("slice", function()
    local joined = d[=[
      []string{"a", "b", "c"}
    ]=]

    local split = d[=[
      []string{
        "a",
        "b",
        "c",
      }
    ]=]

    helpers.make_suite('go', 'splits and joins slice literals', joined, split, '{')
  end)

  describe("map", function()
    local joined = d[=[
      map[string]int{"a": 1, "b": 2, "c": 3}
    ]=]

    local split = d[=[
      map[string]int{
        "a": 1,
        "b": 2,
        "c": 3,
      }
    ]=]

    helpers.make_suite('go', 'splits and joins map literals', joined, split, '{')
  end)

  describe("composite literal", function()
    local joined = d[=[
      User{Name: "a", Age: 1, Email: "b"}
    ]=]

    local split = d[=[
      User{
        Name: "a",
        Age: 1,
        Email: "b",
      }
    ]=]

    helpers.make_suite('go', 'splits and joins composite literals', joined, split, '{')
  end)
end)
