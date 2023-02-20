local d = require'plenary.strings'.dedent

local H = require'test.helpers'

describe('lua', function()

  H.make_suite(
    'lua',
    'list',
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

  H.make_suite(
    'lua',
    'inner list',
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

  H.make_suite(
    'lua',
    'table',
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

  H.make_suite(
    'lua',
    'inner table',
    d[[
      local table = { a = 'a', b = { d = 'd', e = 'e' }, c = 'c' }
    ]],
    d[[
      local table = {
        a = 'a',
        b = {
          d = 'd',
          e = 'e',
        },
        c = 'c',
      }
    ]],
    'd'
  )

  H.make_suite(
    'lua',
    'mixed table',
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

  H.make_suite(
    'lua',
    'inner mixed table',
    d[[
      local mixed = { 1, 2, 3, a = 'a', b = { d = 'd', e = 'e' }, c = 'c' }
    ]],
    d[[
      local mixed = {
        1,
        2,
        3,
        a = 'a',
        b = {
          d = 'd',
          e = 'e',
        },
        c = 'c',
      }
    ]],
    ','
  )

  H.make_suite(
    'lua',
    'params',
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

  H.make_suite(
    'lua',
    'arguments',
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

  H.make_suite(
    'lua',
    'variable_list',
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

  H.make_suite(
    'lua',
    'variable_list in declaration',
    d[[
      local a, b, c = d
    ]],
    d[[
      local
        a,
        b,
        c = d
    ]],
    ','
  )

  H.make_suite(
    'lua',
    'variable_list in indent',
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

  H.make_suite(
    'lua',
    'inner arguments',
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
