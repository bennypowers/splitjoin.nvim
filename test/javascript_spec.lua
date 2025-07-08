local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'javascript'

describe(lang, function()

  H.make_suite(lang, 'noop',
    'const noSplit = 1',
    'const noSplit = 1',
    '1'
  )

  H.make_suite(lang, 'named imports',
    d[[
      import { a, b, c } from 'd'
    ]],
    d[[
      import {
        a,
        b,
        c,
      } from 'd'
    ]],
    ','
  )

  describe('object', function()
    H.make_suite(lang,
      '',
      d[[
        { one: 1, two: 2, three: 3 }
      ]],
      d[[
        {
          one: 1,
          two: 2,
          three: 3,
        }
      ]],
      ','
    )

    H.make_suite(lang,
      'inner',
      d[[
        { one: 1, two: 2, three: { four: 4, five: 5 } }
      ]],
      d[[
        { one: 1, two: 2, three: {
          four: 4,
          five: 5,
        } }
      ]],
      '4'
    )

    H.make_suite(lang,
      'outer',
      d[[
      { one: 1, two: 2, three: { four: 4, five: 5 } }
      ]],
      d[[
      {
        one: 1,
        two: 2,
        three: { four: 4, five: 5 },
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
          3,
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
          4,
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
          [3, 4],
        ]
      ]=],
      '1'
    )

  end)

  describe('parameters', function()

    H.make_suite(lang,
      'function',
      d[[
        function(a, b, c) {}
      ]],
      d[[
        function(
          a,
          b,
          c,
        ) {}
      ]],
      ','
    )

    H.make_suite(lang,
      'arrow',
      d[[
        (a, b, c) => 0
      ]],
      d[[
        (
          a,
          b,
          c,
        ) => 0
      ]],
      ','
    )

    describe('destructured', function()

      H.make_suite(lang,
        'function',
        d[[
          function({ a, b, c }, d) {}
        ]],
        d[[
          function({
            a,
            b,
            c,
          }, d) {}
        ]],
        ','
      )

      H.make_suite(lang,
        'arrow',
        d[[
          ({ a, b, c }, d) => 0
        ]],
        d[[
          ({
            a,
            b,
            c,
          }, d) => 0
        ]],
        ','
      )

    end)

  end)

  describe('arguments', function()

    H.make_suite(lang,
      '',
      d[[
        call(a, b, c)
      ]],
      d[[
        call(
          a,
          b,
          c,
        )
      ]],
      ','
    )

    H.make_suite(lang,
      'with obj and array',
      d[[
        call(a, { b, c }, [d, e])
      ]],
      d[[
        call(
          a,
          { b, c },
          [d, e],
        )
      ]],
      ','
    )

    H.make_suite(lang,
      'outer',
      d[[
        f(a, b, c, g(d, e))
      ]],
      d[[
        f(
          a,
          b,
          c,
          g(d, e),
        )
      ]],
      'a'
    )

    describe('indented', function()

      H.make_suite(lang,
        '',
        d[[
          function thingy(a, b, c) {
            return new Knaidlach(a, b, c);
          }
        ]],
        d[[
          function thingy(a, b, c) {
            return new Knaidlach(
              a,
              b,
              c,
            );
          }
        ]],
        { 2, 24 }
      )

      H.make_suite(lang,
        'inner',
        d[[
        function thingy(a, b, c) {
          return new Knaidlach(a, b, c(d, e));
        }
        ]],
        d[[
        function thingy(a, b, c) {
          return new Knaidlach(a, b, c(
            d,
            e,
          ));
        }
        ]],
        { 2, 32 }
      )

      H.make_suite(lang,
        'outer',
        d[[
          function thingy(a, b, c) {
            return new Knaidlach(a, b, c(d, e));
          }
        ]],
        d[[
          function thingy(a, b, c) {
            return new Knaidlach(
              a,
              b,
              c(d, e),
            );
          }
        ]],
        { 2, 24 }
      )

    end)

  end)

  describe('function()', function()
    H.make_suite(lang, '',
      d[[
        function f() { return 0; }
      ]],
      d[[
        function f() {
          return 0;
        }
      ]],
      'f'
    )
  end)

  describe('jsdoc', function()
    H.make_suite(lang, 'single line jsdoc',
      d[[
        /** jsdoc */
        const x = y => y
      ]],
      d[[
        /**
         * jsdoc
         */
        const x = y => y
      ]],
      'jsdoc'
    )
    H.make_suite(lang, 'indented jsdoc',
      d[[
          /** indented jsdoc */
          const x = y => y
      ]],
      d[[
          /**
           * indented jsdoc
           */
          const x = y => y
      ]],
      'jsdoc'
    )
    H.make_suite(lang, 'multiline jsdoc',
      d[[
        /**
         * multiline
         * jsdoc
         */
        const x = y => y
      ]],
      d[[
        /**
         * multiline
         * jsdoc
         */
        const x = y => y
      ]],
      {2,5}
    )
  end)

  -- describe('const f = function() { return 0; }', function()
  --   H.make_suite(lang, '',
  --     d[[
  --     const f = function() { return 0; }
  --     ]],
  --     d[[
  --     const f = function() {
  --       return 0;
  --     }
  --     ]],
  --     'u'
  --   )
  -- end)
  --
  -- describe('() => 0', function()
  --   H.make_suite(lang, '',
  --     d[[
  --       () => 0
  --     ]],
  --     d[[
  --       () => {
  --         return 0;
  --       }
  --     ]],
  --     '='
  --   )
  -- end)
  --
  -- describe('a => 0', function()
  --   H.make_suite(lang, '',
  --     d[[
  --       a => 0
  --     ]],
  --     d[[
  --       a => {
  --         return 0;
  --       }
  --     ]],
  --     '='
  --   )
  -- end)
  --
  -- describe('() => { const a = 0; return a; }', function()
  --   H.make_suite(lang, '',
  --     d[[
  --       () => { const a = 0; return a; }
  --     ]],
  --     d[[
  --       () => {
  --         const a = 0;
  --         return a;
  --       }
  --     ]],
  --     '='
  --   )
  -- end)
end)
