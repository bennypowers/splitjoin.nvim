local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'rust'

describe(lang, function()

  H.make_suite(lang, 'params',
    d[[
      fn foo(a: i32, b: i32) -> i32 { a + b }
    ]],
    d[[
      fn foo(
        a: i32,
        b: i32,
      ) -> i32 { a + b }
    ]],
    'a:'
  )

  H.make_suite(lang, 'args',
    d[[
      foo(a, b, c);
    ]],
    d[[
      foo(
        a,
        b,
        c,
      );
    ]],
    'a'
  )

  H.make_suite(lang, 'struct fields',
    d[[
      struct Point { x: f64, y: f64 }
    ]],
    d[[
      struct Point {
        x: f64,
        y: f64,
      }
    ]],
    'x'
  )

  H.make_suite(lang, 'enum variants',
    d[[
      enum Color { Red, Green, Blue }
    ]],
    d[[
      enum Color {
        Red,
        Green,
        Blue,
      }
    ]],
    'Red'
  )

  H.make_suite(lang, 'use list',
    d[[
      use std::collections::{HashMap, HashSet, BTreeMap};
    ]],
    d[[
      use std::collections::{
        HashMap,
        HashSet,
        BTreeMap,
      };
    ]],
    'HashMap'
  )

  H.make_suite(lang, 'tuple',
    d[[
      let t = (1, 2, 3);
    ]],
    d[[
      let t = (
        1,
        2,
        3,
      );
    ]],
    '1'
  )

end)
