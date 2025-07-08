local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'go'

describe(lang, function()
  H.make_suite(lang, 'struct',
    d[[
      type User struct { Name string; Age int; Email string }
    ]],
    d[[
      type User struct {
        Name string
        Age int
        Email string
      }
    ]],
    '{'
  )

  H.make_suite(lang, 'params',
    d[[
      func Foo(a int, b string) (int, error) {}
    ]],
    d[[
      func Foo(
        a int,
        b string,
      ) (int, error) {}
    ]],
    'a'
  )

  H.make_suite(lang, 'return',
    d[[
      func Foo(a int, b string) (int, error) {}
    ]],
    d[[
      func Foo(a int, b string) (
        int,
        error,
      ) {}
    ]],
    'error'
  )

  H.make_suite(lang, 'args',
    d[[
      Foo(a, b, c)
    ]],
    d[[
      Foo(
        a,
        b,
        c,
      )
    ]],
    'a'
  )

  H.make_suite(lang, 'slice',
    d[=[
      []string{"a", "b", "c"}
    ]=],
    d[=[
      []string{
        "a",
        "b",
        "c",
      }
    ]=],
    '{'
  )

  H.make_suite(lang, 'map',
    d[=[
      map[string]int{"a": 1, "b": 2, "c": 3}
    ]=],
    d[=[
      map[string]int{
        "a": 1,
        "b": 2,
        "c": 3,
      }
    ]=],
    '{'
  )

  H.make_suite(lang, 'composite literal',
    d[=[
      User{Name: "a", Age: 1, Email: "b"}
    ]=],
    d[=[
      User{
        Name: "a",
        Age: 1,
        Email: "b",
      }
    ]=],
    '{'
  )
end)
