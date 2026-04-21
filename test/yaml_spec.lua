local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'yaml'

describe(lang, function()

  H.make_suite(lang, 'flow sequence (scalar, block-style)',
    d[[
      list: [1, 2, 3]
    ]],
    d[[
      list:
        - 1
        - 2
        - 3
    ]],
    '1'
  )

  H.make_suite(lang, 'flow sequence (non-scalar, bracket-style)',
    d[=[
      awful: [string, 0, {refactor: this}, pal]
    ]=],
    d[=[
      awful: [
        string,
        0,
        {refactor: this},
        pal,
      ]
    ]=],
    'string'
  )

  H.make_suite(lang, 'flow sequence (nested indent)',
    d[[
      on:
        pull_request:
          types: [opened, synchronize, reopened]
    ]],
    d[[
      on:
        pull_request:
          types:
            - opened
            - synchronize
            - reopened
    ]],
    'opened'
  )

  H.make_suite(lang, 'flow mapping',
    d[=[
      map: {a: 1, b: 2}
    ]=],
    d[=[
      map: {
        a: 1,
        b: 2,
      }
    ]=],
    'a:'
  )

end)
