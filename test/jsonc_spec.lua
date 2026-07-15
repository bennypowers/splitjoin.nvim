local d = require'plenary.strings'.dedent

local H = require'test.helpers'

local lang = 'jsonc'

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
  end)

  describe('object with comment', function()
    H.make_suite(lang,
      '',
      d[[
        { /* label */ "one": 1, "two": 2 }
      ]],
      d[[
        {
          /* label */ "one": 1,
          "two": 2
        }
      ]],
      ','
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

  end)
end)

describe('aliases', function()
  local Options = require'splitjoin.util.options'

  it('resolves built-in alias', function()
    assert.same('json', Options.resolve_lang('jsonc'))
  end)

  it('returns identity for unknown lang', function()
    assert.same('lua', Options.resolve_lang('lua'))
  end)

  it('user alias overrides built-in', function()
    vim.g.splitjoin = { aliases = { jsonc = 'yaml' } }
    assert.same('yaml', Options.resolve_lang('jsonc'))
    vim.g.splitjoin = nil
  end)

  it('user alias adds new mapping', function()
    vim.g.splitjoin = { aliases = { custom = 'json' } }
    assert.same('json', Options.resolve_lang('custom'))
    vim.g.splitjoin = nil
  end)

  it('false disables built-in alias', function()
    vim.g.splitjoin = { aliases = { jsonc = false } }
    assert.same('jsonc', Options.resolve_lang('jsonc'))
    vim.g.splitjoin = nil
  end)

  it('user language config on aliased lang inherits from target', function()
    local splitjoin = require'splitjoin'
    splitjoin.setup({
      languages = {
        jsonc = {
          nodes = {
            object = { padding = '' },
          },
        },
      },
    })
    local opts = Options.get_options_for('jsonc', 'object')
    assert.same('', opts.padding)
    assert.same('{', opts.surround[1])
    assert.same('}', opts.surround[2])
    splitjoin.setup({})
  end)
end)
