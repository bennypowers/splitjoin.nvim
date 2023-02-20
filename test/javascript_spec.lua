local strings = require'plenary.strings'

local H = require'test.helpers'

describe('javascript', function()
  H.make_suite(
    'javascript',
    'object',
    '{ one: 1, two: 2, three: 3 }',
    strings.dedent[[
      {
        one: 1,
        two: 2,
        three: 3,
      }]],
    ','
  )

  H.make_suite(
    'javascript',
    'array',
    '[1, 2, 3]',
    strings.dedent[==[
      [
        1,
        2,
        3,
      ]]==],
    ','
  )

  H.make_suite(
    'javascript',
    'arrow params',
    '(a, b, c) => 0',
    strings.dedent[[
      (
        a,
        b,
        c,
      ) => 0]],
    ','
  )

  H.make_suite(
    'javascript',
    'arguments',
    'call(a, b, c)',
    strings.dedent[[
      call(
        a,
        b,
        c,
      )]],
    ','
  )

  H.make_suite(
    'javascript',
    'noop',
    'const noSplit = 1',
    'const noSplit = 1',
    ','
  )

  H.make_suite(
    'javascript',
    'base indent',
    strings.dedent[[
      function thingy(a, b, c) {
        return new Knaidlach(a, b, c);
      }
    ]],
    strings.dedent[[
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
