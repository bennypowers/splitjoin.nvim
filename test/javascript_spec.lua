local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'javascript'

describe(lang, function()

  H.make_suite(lang,
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

  H.make_suite(lang,
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

  H.make_suite(lang,
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

  H.make_suite(lang,
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

  H.make_suite(lang,
    'noop',
    'const noSplit = 1',
    'const noSplit = 1',
    '1'
  )

  H.make_suite(lang,
    'named imports',
    d[[
      import { a, b, c } from 'd'
    ]],
    d[[
      import {
        a,
        b,
        c,
      } from 'd'
    ]],
    ','
  )

  H.make_suite(lang,
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

  H.make_suite(lang,
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

  H.make_suite(lang,
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
    '3'
  )

  H.make_suite(lang,
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
    'd'
  )

end)
