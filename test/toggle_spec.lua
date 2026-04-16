local d = require'plenary.strings'.dedent
local H = require'test.helpers'

describe('toggle', function()

  H.make_toggle_suite('javascript', 'array',
    d[[
      [1, 2, 3]
    ]],
    d[[
      [
        1,
        2,
        3,
      ]
    ]],
    '1'
  )

  H.make_toggle_suite('lua', 'table',
    d[[
      { a = 1, b = 2, c = 3 }
    ]],
    d[[
      {
        a = 1,
        b = 2,
        c = 3,
      }
    ]],
    'a'
  )

  H.make_toggle_suite('python', 'list',
    d[=[
      x = [1, 2, 3]
    ]=],
    d[=[
      x = [
          1,
          2,
          3,
      ]
    ]=],
    '1'
  )

  H.make_toggle_suite('go', 'args',
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

end)
