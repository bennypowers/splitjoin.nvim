
local strings = require'plenary.strings'

local H = require'test.helpers'

describe('lua', function()
  H.make_suite(
    'lua',
    'list',
    'local list = { 1, 2, 3 }',
    strings.dedent[[
      local list = {
        1,
        2,
        3,
      }]],
    ','
  )

  H.make_suite(
    'lua',
    'table',
    "local table = { a = 'a', b = 'b', c = 'c' }",
    strings.dedent[[
      local table = {
        a = 'a',
        b = 'b',
        c = 'c',
      }]],
    ','
  )

  H.make_suite(
    'lua',
    'mixed table',
    "local mixed = { 1, 2, 3, a = 'a', b = 'b', c = 'c' }",
    strings.dedent[[
      local mixed = {
        1,
        2,
        3,
        a = 'a',
        b = 'b',
        c = 'c',
      }]],
    ','
  )

  H.make_suite(
    'lua',
    'params',
    'local function call(a, b, c) end',
    strings.dedent[[
      local function call(
        a,
        b,
        c
      ) end]],
    ','
  )

  H.make_suite(
    'lua',
    'arguments',
    'call(a, b, c)',
    strings.dedent[[
      call(
        a,
        b,
        c
      )]],
    ','
  )

  H.make_suite(
    'lua',
    'variable_list',
    'a, b, c = d',
    strings.dedent[[
      a,
      b,
      c = d]],
    ','
  )

end)
