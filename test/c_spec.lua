local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'c'

describe(lang, function()

  H.make_suite(lang, 'params',
    d[[
      void foo(int a, int b, int c) {}
    ]],
    d[[
      void foo(
        int a,
        int b,
        int c
      ) {}
    ]],
    'int a'
  )

  H.make_suite(lang, 'initializer list',
    d[[
      int arr[] = {1, 2, 3};
    ]],
    d[[
      int arr[] = {
        1,
        2,
        3,
      };
    ]],
    '1'
  )

  H.make_suite(lang, 'enum',
    d[[
      enum color { RED, GREEN, BLUE };
    ]],
    d[[
      enum color {
        RED,
        GREEN,
        BLUE,
      };
    ]],
    'RED'
  )

end)
