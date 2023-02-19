local strings = require'plenary.strings'

local H = require'test.helpers'

describe('typescript', function()
  H.make_suite(
    'typescript',
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
    'typescript',
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
    'typescript',
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
    'typescript',
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
    'typescript',
    'noop',
    'const noSplit = 1',
    'const noSplit = 1',
    ','
  )

  H.make_suite(
    'typescript',
    'unions',
    'type A = 1|2|3;',
    strings.dedent[[
      type A =
        | 1
        | 2
        | 3;
      )]],
    '|'
  )

end)
