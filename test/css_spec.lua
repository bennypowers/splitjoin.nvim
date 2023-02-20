local d = require'plenary.strings'.dedent

local H = require'test.helpers'

describe('css', function()
  H.make_suite(
    'css',
    'block',
    d[[
      a { color: blue; font: 12px "Fira Code", monospace }
    ]],
    d[[
      a {
        color: blue;
        font: 12px "Fira Code", monospace;
      }
    ]],
    ';'
  )
end)
