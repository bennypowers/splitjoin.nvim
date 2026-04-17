local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'css'

describe(lang, function()

  describe('block', function()

    H.make_suite(lang, '',
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

    H.make_suite(lang, 'string containing sep',
      d[[
        a { content: ";" }
      ]],
      d[[
        a {
          content: ";";
        }
      ]],
      'c'
    )

    H.make_suite(lang, 'with list',
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

    H.make_suite(lang, 'arguments',
      d[[
        :is(h1, h2, h3) { color: blue }
      ]],
      d[[
        :is(
          h1,
          h2,
          h3
        ) { color: blue }
      ]],
      '1'
    )

    H.make_suite(lang, 'arguments with multi-word values',
      d[[
        background: linear-gradient(to bottom, #d4d3d2, #dbdad9);
      ]],
      d[[
        background: linear-gradient(
          to bottom,
          #d4d3d2,
          #dbdad9
        );
      ]],
      'to bottom'
    )

    H.make_suite(lang, 'arguments with nested function calls',
      d[[
        background: linear-gradient(to bottom, light-dark(#d4d3d2, #333333), light-dark(#dbdad9, #383838), light-dark(#e2e1e0, #3c3c3c), light-dark(#eaeae9, #404040));
      ]],
      d[[
        background: linear-gradient(
          to bottom,
          light-dark(#d4d3d2, #333333),
          light-dark(#dbdad9, #383838),
          light-dark(#e2e1e0, #3c3c3c),
          light-dark(#eaeae9, #404040)
        );
      ]],
      'to bottom'
    )

  end)

  describe('declaration', function()

    H.make_suite(lang, 'font list',
      d[[
        a { font: 12px "Fira Code", monospace; }
      ]],
      d[[
        a { font:
          12px
          "Fira Code",
          monospace; }
      ]],
      '12px'
    )

    H.make_suite(lang, 'transition list',
      d[[
        a { transition: color 0.3s, background 0.3s; }
      ]],
      d[[
        a { transition:
          color
          0.3s,
          background
          0.3s; }
      ]],
      'color'
    )

  end)

end)
