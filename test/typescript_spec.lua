local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'typescript'

describe(lang, function()

  H.make_suite(lang, 'array',
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

  H.make_suite(lang, 'arrow params',
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

  H.make_suite(lang, 'unions',
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

  H.make_suite(lang, 'type params',
    d[[
      class A<B, C> {}
    ]],
    d[[
      class A<
        B,
        C,
      > {}
    ]],
    ','
  )

  H.make_suite(lang, 'type arguments',
    d[[
      f<A, B>()
    ]],
    d[[
      f<
        A,
        B
      >()
    ]],
    ','
  )

end)
