--- Options functions
local Options = {}

local function copy(tbl)
  return vim.tbl_deep_extend('keep', tbl, {})
end

local function try_require(spec)
  local y, o = pcall(require, spec)
  return y and o or {}
end

local function get_defaults()
  local defaults = {
    languages = {
      -- TODO: generate these
      lua = require'splitjoin.languages.lua.defaults',
      ecmascript = require'splitjoin.languages.ecmascript.defaults',
      javascript = require'splitjoin.languages.javascript.defaults',
      typescript = require'splitjoin.languages.typescript.defaults',
      jsdoc = require'splitjoin.languages.jsdoc.defaults',
      json = require'splitjoin.languages.json.defaults',
      html = require'splitjoin.languages.html.defaults',
      css = require'splitjoin.languages.css.defaults',
    },
  }
  for name, mod in pairs(defaults.languages) do
    if mod.extends and defaults.languages[mod.extends] then
      defaults.languages[name] = vim.tbl_deep_extend('keep', mod, defaults.languages[mod.extends])
    end
  end
  return copy(defaults)
end

local OPTIONS = get_defaults()

-- CONFIG AND OPTS
function Options.get_options_for(lang, type)
  local _, options = pcall(function() return OPTIONS.languages[lang] end)
  options = options or {}
  options.nodes = options.nodes or {}
  return options.nodes[type] or {}
end

function Options.setup(opts)
  for lang, mod in pairs(OPTIONS.languages) do
    local original = OPTIONS.languages[lang]
    local options = try_require('splitjoin.languages.'..lang..'.options')
    local passed = opts and opts.languages and opts.languages[lang] or {}
    local parent = try_require('splitjoin.languages.' .. (mod.extends or '.') ..'.options')
    local defaults = get_defaults().languages[lang]
    OPTIONS.languages[lang] =
      vim.tbl_deep_extend('force', original, options, parent, mod, passed, defaults)
  end
end

Options.setup()

return Options
