local d = require'plenary.strings'.dedent
local H = require'test.helpers'

local lang = 'nix'

describe(lang, function()

  H.make_suite(lang, 'list',
    d[[
      buildInputs = [ pkg1 pkg2 pkg3 ];
    ]],
    d[[
      buildInputs = [
        pkg1
        pkg2
        pkg3
      ];
    ]],
    'pkg1'
  )

  H.make_suite(lang, 'single element list',
    d[[
      buildInputs = [ pkg1 ];
    ]],
    d[[
      buildInputs = [ pkg1 ];
    ]],
    'pkg1'
  )

  H.make_suite(lang, 'list with paths',
    d[[
      nativeBuildInputs = [ cmake ninja pkg-config ];
    ]],
    d[[
      nativeBuildInputs = [
        cmake
        ninja
        pkg-config
      ];
    ]],
    'cmake'
  )

  H.make_suite(lang, 'list with function calls',
    d[[
      { x = [ (callPackage ./foo.nix {}) pkg2 ]; }
    ]],
    d[[
      { x = [
        (callPackage ./foo.nix {})
        pkg2
      ]; }
    ]],
    'callPackage'
  )

  H.make_suite(lang, 'list with strings',
    d[=[
      { x = [ "hello" "world" ]; }
    ]=],
    d[=[
      { x = [
        "hello"
        "world"
      ]; }
    ]=],
    'hello'
  )

  H.make_suite(lang, 'indented list',
    d[[
      {
        buildInputs = [ pkg1 pkg2 pkg3 ];
      }
    ]],
    d[[
      {
        buildInputs = [
          pkg1
          pkg2
          pkg3
        ];
      }
    ]],
    'pkg1'
  )

end)
