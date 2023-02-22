local H = require'test.helpers'

local d = require'plenary.strings'.dedent

local lang = 'lua'

describe(lang, function()

  H.make_suite(lang, 'list',
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

  H.make_suite(lang, 'table',
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

  H.make_suite(lang, 'mixed table',
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

  H.make_suite(lang, 'variable_list',
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

  H.make_suite(lang, 'variable_list in declaration',
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

  H.make_suite(lang, 'variable_list in indent',
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

  H.make_suite(lang, 'variable_list declaration in indent',
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
    { 2, 4 }
  )

  H.make_suite(lang, 'if',
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

  H.make_suite(lang, 'if this and that',
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

  H.make_suite(lang, 'if else',
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

  H.make_suite(lang, 'if elseif else',
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

  H.make_suite(lang, 'indented if elseif else',
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
    { 2, 4 }
  )

  H.make_suite(lang, 'inner list',
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

  H.make_suite(lang, 'inner table',
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

  H.make_suite(lang, 'inner mixed table',
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

  H.make_suite(lang, 'inner double mixed table',
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

  H.make_suite(lang, 'inner arguments',
    d[[
      f(a, b, c, g(d, e))
    ]],
    d[[
      f(a, b, c, g(
        d,
        e
      ))
    ]],
    { 1, 14 }
  )

end)
