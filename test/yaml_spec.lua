local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'yaml'

describe(lang, function()

  H.make_suite(lang, 'flow sequence',
    d[[
      list: [1, 2, 3]
    ]],
    d[[
      list: [
        1,
        2,
        3,
      ]
    ]],
    '1'
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
