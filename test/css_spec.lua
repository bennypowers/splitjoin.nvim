local strings = require'plenary.strings'

local H = require'test.helpers'

describe('css', function()
  H.make_suite(
    'css',
    'block',
    'a { color: blue; font: 12px "Fira Code", monospace }',
    strings.dedent[[
      a {
        color: blue;
        font: 12px "Fira Code", monospace;
      }]],
    ';'
  )
end)
