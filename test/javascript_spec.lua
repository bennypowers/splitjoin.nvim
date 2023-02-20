local d = require'plenary.strings'.dedent

local H = require'test.helpers'

describe('javascript', function()

  H.make_suite(
    'javascript',
    'object',
    d[[
      { one: 1, two: 2, three: 3 }
    ]],
    d[[
      {
        one: 1,
        two: 2,
        three: 3,
      }
    ]],
    ','
  )

  H.make_suite(
    'javascript',
    'inner object',
    d[[
      { one: 1, two: 2, three: { four: 4, five: 5 } }
    ]],
    d[[
      { one: 1, two: 2, three: {
        four: 4,
        five: 5,
      } }
    ]],
    '4'
  )

  H.make_suite(
    'javascript',
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
    'javascript',
    'inner array',
    d[=[
      [1, 2, [3, 4]]
    ]=],
    d[=[
      [1, 2, [
        3,
        4,
      ]]
    ]=],
    ','
  )

  H.make_suite(
    'javascript',
    'arrow params',
    d[[
      (a, b, c) => 0
    ]],
    d[[
      (
        a,
        b,
        c,
      ) => 0
    ]],
    ','
  )

  H.make_suite(
    'javascript',
    'arguments',
    d[[
      call(a, b, c)
    ]],
    d[[
      call(
        a,
        b,
        c,
      )
    ]],
    ','
  )

  H.make_suite(
    'lua',
    'inner arguments',
    d[[
      f(a, b, c, g(d, e))
    ]],
    d[[
      f(a, b, c, g(
        d,
        e,
      ))
    ]],
    { 1, 14 }
  )


  H.make_suite(
    'javascript',
    'noop',
    'const noSplit = 1',
    'const noSplit = 1',
    '1'
  )

  H.make_suite(
    'javascript',
    'base indent',
    d[[
      function thingy(a, b, c) {
        return new Knaidlach(a, b, c);
      }
    ]],
    d[[
      function thingy(a, b, c) {
        return new Knaidlach(
          a,
          b,
          c,
        );
      }
    ]],
    { 2, 24 }
  )

end)
