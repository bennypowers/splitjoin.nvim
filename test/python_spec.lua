local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'python'

describe(lang, function()

  H.make_suite(lang, 'params',
    d[[
      def foo(a, b, c):
          pass
    ]],
    d[[
      def foo(
          a,
          b,
          c,
      ):
          pass
    ]],
    'a'
  )

  H.make_suite(lang, 'args',
    d[[
      foo(1, 2, 3)
    ]],
    d[[
      foo(
          1,
          2,
          3,
      )
    ]],
    '1'
  )

  H.make_suite(lang, 'list',
    d[=[
      x = [1, 2, 3]
    ]=],
    d[=[
      x = [
          1,
          2,
          3,
      ]
    ]=],
    '1'
  )

  H.make_suite(lang, 'dict',
    d[=[
      x = {"a": 1, "b": 2, "c": 3}
    ]=],
    d[=[
      x = {
          "a": 1,
          "b": 2,
          "c": 3,
      }
    ]=],
    '"a"'
  )

  H.make_suite(lang, 'tuple',
    d[[
      x = (1, 2, 3)
    ]],
    d[[
      x = (
          1,
          2,
          3,
      )
    ]],
    '1'
  )

  H.make_suite(lang, 'set',
    d[=[
      x = {1, 2, 3}
    ]=],
    d[=[
      x = {
          1,
          2,
          3,
      }
    ]=],
    '1'
  )

  H.make_suite(lang, 'nested list inner',
    d[=[
      x = [1, 2, [3, 4]]
    ]=],
    d[=[
      x = [1, 2, [
          3,
          4,
      ]]
    ]=],
    '3'
  )

  H.make_suite(lang, 'single element list',
    d[=[
      x = [1]
    ]=],
    d[=[
      x = [
          1,
      ]
    ]=],
    '1'
  )

  H.make_suite(lang, 'indented in function',
    d[=[
      def foo():
          x = [1, 2, 3]
    ]=],
    d[=[
      def foo():
          x = [
              1,
              2,
              3,
          ]
    ]=],
    '1'
  )

  H.make_suite(lang, 'nested list outer',
    d[=[
      x = [1, 2, [3, 4]]
    ]=],
    d[=[
      x = [
          1,
          2,
          [3, 4],
      ]
    ]=],
    '1'
  )

end)
