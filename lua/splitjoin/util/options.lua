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
      go = require'splitjoin.languages.go.defaults',
      python = require'splitjoin.languages.python.defaults',
    },
  }
  for name, mod in pairs(defaults.languages) do
    if mod.extends and defaults.languages[mod.extends] then
      defaults.languages[name] = vim.tbl_deep_extend('keep', mod, defaults.languages[mod.extends])
    end
  end
  return copy(defaults)
end

local OPTIONS = nil

local function ensure_initialized()
  if OPTIONS then return end
  OPTIONS = get_defaults()
  local user_config = vim.g.splitjoin
  if type(user_config) == 'function' then user_config = user_config() end
  for lang, mod in pairs(OPTIONS.languages) do
    local lang_options = try_require('splitjoin.languages.'..lang..'.options')
    local parent_options = try_require('splitjoin.languages.' .. (mod.extends or '.') ..'.options')
    local passed = user_config and user_config.languages and user_config.languages[lang] or {}
    OPTIONS.languages[lang] =
      vim.tbl_deep_extend('force', OPTIONS.languages[lang], parent_options, lang_options, passed)
    -- Propagate language-level default_indent to nodes that don't define their own
    local di = OPTIONS.languages[lang].default_indent
    if di then
      for _, node_opts in pairs(OPTIONS.languages[lang].nodes or {}) do
        if node_opts.default_indent == nil then
          node_opts.default_indent = di
        end
      end
    end
  end
end

-- CONFIG AND OPTS
function Options.get_options_for(lang, type)
  ensure_initialized()
  local lang_opts = OPTIONS.languages[lang] or {}
  return (lang_opts.nodes or {})[type] or {}
end

function Options.setup(opts)
  vim.g.splitjoin = opts
  OPTIONS = nil
end

return Options
