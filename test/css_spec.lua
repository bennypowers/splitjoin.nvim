local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'css'

describe(lang, function()

  H.make_suite(lang, 'block',
    d[[
      a { color: blue }
    ]],
    d[[
      a {
        color: blue;
      }
    ]],
    ':'
  )

  H.make_suite(lang, 'block with list',
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
