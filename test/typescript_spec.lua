local d = require'plenary.strings'.dedent

local H = require'test.helpers'

describe('typescript', function()

  H.make_suite(
    'typescript',
    'array',
    d[=[
      [1, 2, 3]
    ]=],
    d[=[
      [
        1,
        2,
        3,
      ]
    ]=],
    ','
  )

  H.make_suite(
    'typescript',
    'arrow params',
    d[[
      (a: A, b: B, c: C) => 0
    ]],
    d[[
      (
        a: A,
        b: B,
        c: C,
      ) => 0
    ]],
    ','
  )

  H.make_suite(
    'typescript',
    'unions',
    d[[
      type A = 1|2|3;
    ]],
    d[[
      type A =
        | 1
        | 2
        | 3;
    ]],
    '|'
  )

end)
