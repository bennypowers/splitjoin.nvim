local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'html'

describe(lang, function()

  describe('attrs', function()

    H.make_suite(lang, '',
      d[[
      <a id="a" href="#">Hi</a>
      ]],
      d[[
      <a id="a"
          href="#">Hi</a>
      ]],
      'i'
    )

    H.make_suite(lang, 'on void element',
      d[[
      <img id="a" hidden>
      ]],
      d[[
      <img id="a"
          hidden>
      ]],
      'd'
    )

    describe('aligned', function()
      before_each(function()
        require'splitjoin'.setup {
          languages = {
            html = {
              nodes = {
                attribute = {
                  aligned = true,
                }
              }
            }
          }
        }
      end)

      H.make_suite(lang, '',
        d[[
        <a id="a" href="#" hidden>Hi</a>
        ]],
        d[[
        <a id="a"
           href="#"
           hidden>Hi</a>
        ]],
        'i'
      )

      H.make_suite(lang, 'on void element',
        d[[
        <img id="a" src="p.png" hidden>
        ]],
        d[[
        <img id="a"
             src="p.png"
             hidden>
        ]],
        'd'
      )

      end)

    end)

  describe('children', function()

    H.make_suite(lang, '',
      d[[
      <a id="a" href="#">Hi</a>
      ]],
      d[[
      <a id="a" href="#">
        Hi
      </a>
      ]],
      'a'
    )

    H.make_suite(lang, 'on text node',
      d[[
      <a id="a" href="#">Hi</a>
      ]],
      d[[
      <a id="a" href="#">
        Hi
      </a>
      ]],
      'H'
    )
  end)

end)
