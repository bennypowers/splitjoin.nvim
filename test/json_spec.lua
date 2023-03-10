local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'json'

describe(lang, function()

  describe('object', function()
    H.make_suite(lang,
      '',
      d[[
        { "one": 1, "two": 2, "three": 3 }
      ]],
      d[[
        {
          "one": 1,
          "two": 2,
          "three": 3
        }
      ]],
      ','
    )

    H.make_suite(lang,
      'inner',
      d[[
        { "one": 1, "two": 2, "three": { "four": 4, "five": 5 } }
      ]],
      d[[
        { "one": 1, "two": 2, "three": {
          "four": 4,
          "five": 5
        } }
      ]],
      '4'
    )

    H.make_suite(lang,
      'outer',
      d[[
      { "one": 1, "two": 2, "three": { "four": 4, "five": 5 } }
      ]],
      d[[
      {
        "one": 1,
        "two": 2,
        "three": { "four": 4, "five": 5 }
      }
      ]],
      'o'
    )

  end)

  describe('array', function()

    H.make_suite(lang,
      '',
      d[=[
        [1, 2, 3]
      ]=],
      d[=[
        [
          1,
          2,
          3
        ]
      ]=],
      ','
    )

    H.make_suite(lang,
      'inner',
      d[=[
        [1, 2, [3, 4]]
      ]=],
      d[=[
        [1, 2, [
          3,
          4
        ]]
      ]=],
      '3'
    )

    H.make_suite(lang,
      'outer',
      d[=[
        [1, 2, [3, 4]]
      ]=],
      d[=[
        [
          1,
          2,
          [3, 4]
        ]
      ]=],
      '1'
    )

  end)
end)
