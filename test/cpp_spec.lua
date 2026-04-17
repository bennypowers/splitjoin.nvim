local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'cpp'

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
      std::vector<int> v = {1, 2, 3};
    ]],
    d[[
      std::vector<int> v = {
        1,
        2,
        3,
      };
    ]],
    '1'
  )

  H.make_suite(lang, 'template params',
    d[[
      template<typename T, typename U> class Foo {};
    ]],
    d[[
      template<
        typename T,
        typename U
      > class Foo {};
    ]],
    'typename T'
  )

end)
