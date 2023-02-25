local H = require'test.helpers'

local d = require'plenary.strings'.dedent

local lang = 'lua'

describe(lang, function()

  describe('tables', function()

    H.make_suite(lang, 'list-like',
      d[[
        local list = { 1, 2, 3 }
      ]],
      d[[
        local list = {
          1,
          2,
          3,
        }
      ]],
      ','
    )

    H.make_suite(lang, 'associative',
      d[[
        local table = { a = 'a', b = 'b', c = 'c' }
      ]],
      d[[
        local table = {
          a = 'a',
          b = 'b',
          c = 'c',
        }
      ]],
      ','
    )

    H.make_suite(lang, 'mixed',
      d[[
        local mixed = { 1, 2, 3, a = 'a', b = 'b', c = 'c' }
      ]],
      d[[
        local mixed = {
          1,
          2,
          3,
          a = 'a',
          b = 'b',
          c = 'c',
        }
      ]],
      ','
    )

    describe('inner', function()

      H.make_suite(lang, 'list',
        d[[
          local list = { 1, 2, { 3, 4 } }
        ]],
        d[[
          local list = { 1, 2, {
            3,
            4,
          } }
        ]],
        '3'
      )

      H.make_suite(lang, 'table',
        d[[
          local table = { a = 'a', b = { d = 'd', e = 'e' }, c = 'c' }
        ]],
        d[[
          local table = { a = 'a', b = {
            d = 'd',
            e = 'e',
          }, c = 'c' }
        ]],
        'd'
      )

      H.make_suite(lang, 'mixed table',
        d[[
          local mixed = { 1, 2, 3, a = 'a', b = { d = 'd', e = 'e' }, c = 'c' }
        ]],
        d[[
          local mixed = { 1, 2, 3, a = 'a', b = {
            d = 'd',
            e = 'e',
          }, c = 'c' }
        ]],
        { 1, 43 }
      )

      H.make_suite(lang, 'double mixed table',
        d[[
          local mixed = { 1, 2, 3, a = 'a', b = { d = 'd', e = 'e' }, c = { 4, 5, 6 } }
        ]],
        d[[
          local mixed = { 1, 2, 3, a = 'a', b = {
            d = 'd',
            e = 'e',
          }, c = { 4, 5, 6 } }
        ]],
        { 1, 43 }
      )

    end)

    describe('outer', function()

      H.make_suite(lang, 'list',
        d[[
          local list = { 1, 2, { 3, 4 } }
        ]],
        d[[
          local list = {
            1,
            2,
            { 3, 4 },
          }
        ]],
        '2'
      )

      H.make_suite(lang, 'table',
        d[[
          local table = { a = 'a', b = { d = 'd', e = 'e' }, c = 'c' }
        ]],
        d[[
          local table = {
            a = 'a',
            b = { d = 'd', e = 'e' },
            c = 'c',
          }
        ]],
        { 1, 18 }
      )

      H.make_suite(lang, 'mixed table',
        d[[
          local mixed = { 1, 2, 3, a = 'a', b = { d = 'd', e = 'e' }, c = 'c' }
        ]],
        d[[
          local mixed = {
            1,
            2,
            3,
            a = 'a',
            b = { d = 'd', e = 'e' },
            c = 'c',
          }
        ]],
        '2'
      )

      H.make_suite(lang, 'double mixed table',
        d[[
          local mixed = { 1, 2, 3, a = 'a', b = { d = 'd', e = 'e' }, c = { 4, 5, 6 } }
        ]],
        d[[
          local mixed = {
            1,
            2,
            3,
            a = 'a',
            b = { d = 'd', e = 'e' },
            c = { 4, 5, 6 },
          }
        ]],
        '2'
      )

    end)
  end)

  describe('functions', function()

    H.make_suite(lang, 'params',
      d[[
        local function call(
          a,
          b,
          c
        ) end
      ]],
      d[[
        local function call(
          a,
          b,
          c
        ) end
      ]],
      ','
    )

    H.make_suite(lang, 'arguments',
      d[[
        call(a, b, c)
      ]],
      d[[
        call(
          a,
          b,
          c
        )
      ]],
      ','
    )

    describe('inner', function()

      H.make_suite(lang, 'arguments',
        d[[
          f(a, b, c, g(d, e))
        ]],
        d[[
          f(a, b, c, g(
            d,
            e
          ))
        ]],
        'd'
      )

      H.make_suite(lang, 'indented arguments',
        d[[
          if thing then
            f(a, b, c, g(d, e))
          end
        ]],
        d[[
          if thing then
            f(a, b, c, g(
              d,
              e
            ))
          end
        ]],
        { 2, 16 }
      )

    end)

    describe('outer', function()

      H.make_suite(lang, 'arguments',
        d[[
          f(a, b, c, g(d, e))
        ]],
        d[[
          f(
            a,
            b,
            c,
            g(d, e)
          )
        ]],
        'a'
      )

      H.make_suite(lang, 'indented arguments',
        d[[
          if thing then
            f(a, b, c, g(d, e))
          end
        ]],
        d[[
          if thing then
            f(
              a,
              b,
              c,
              g(d, e)
            )
          end
        ]],
        { 2, 5 }
      )

    end)
  end)

  describe('variable lists', function()

    H.make_suite(lang, 'global',
      d[[
        a, b, c = d
      ]],
      d[[
        a,
        b,
        c = d
      ]],
      ','
    )

    H.make_suite(lang, 'local',
      d[[
        local a, b, c = d
      ]],
      d[[
        local a,
              b,
              c = d
      ]],
      ','
    )

    H.make_suite(lang, 'indented',
      d[[
        local function params(a, b, c)
          a, b, c = mod(a, b, c)
        end
      ]],
      d[[
        local function params(a, b, c)
          a,
          b,
          c = mod(a, b, c)
        end
      ]],
      { 2, 4 }
    )

    H.make_suite(lang, 'local indented',
      d[[
        local function params(a, b, c)
          local a, b, c = mod(a, b, c)
        end
      ]],
      d[[
        local function params(a, b, c)
          local a,
                b,
                c = mod(a, b, c)
        end
      ]],
      { 2, 10 }
    )

  end)

  describe('if', function()

    H.make_suite(lang, 'then',
      d[[
      if this then that() end
      ]],
      d[[
      if this then
        that()
      end
      ]],
      'i'
    )

    H.make_suite(lang, 'and',
      d[[
      if this and that then theother() end
      ]],
      d[[
      if this and that then
        theother()
      end
      ]],
      'i'
    )

    H.make_suite(lang, '(and)',
      d[[
      if (this and that) then theother() end
      ]],
      d[[
      if (this and that) then
        theother()
      end
      ]],
      'i'
    )

    H.make_suite(lang, 'else',
      d[[
      if this then theother() else thefirst() end
      ]],
      d[[
      if this then
        theother()
      else
        thefirst()
      end
      ]],
      'i'
    )

    H.make_suite(lang, 'elseif',
      d[[
      if this then that() elseif theother then thefirst() else otherwise() end
      ]],
      d[[
      if this then
        that()
      elseif theother then
        thefirst()
      else
        otherwise()
      end
      ]],
      'i'
    )

    H.make_suite(lang, 'nested elseif',
      d[[
      if this then that() elseif theother then thefirst() else otherwise() if did then cool else fail() end end
      ]],
      d[[
      if this then
        that()
      elseif theother then
        thefirst()
      else
        otherwise() if did then cool else fail() end
      end
      ]],
      'i'
    )

    describe('indented', function()

      H.make_suite(lang, 'elseif',
        d[[
        function hi()
          if this then that() elseif theother then thefirst() else otherwise() end
        end
        ]],
        d[[
        function hi()
          if this then
            that()
          elseif theother then
            thefirst()
          else
            otherwise()
          end
        end
        ]],
        { 2, 2 }
      )

    end)
  end)

end)
