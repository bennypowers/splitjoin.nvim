local M = {}

---@class SplitjoinLanguageConfig
---@field default_indent string
---@field no_trailing_comma table<string, boolean>
---@field pad table<string, boolean>
---@field surround table<string, boolean>

local DEFAULT_OPTIONS = {
  languages = {
    lua = require'splitjoin.languages.lua',
    ecmascript = require'splitjoin.languages.ecmascript',
    javascript = require'splitjoin.languages.javascript',
    typescript = require'splitjoin.languages.typescript',
    css = require'splitjoin.languages.css',
  },
}

for name, mod in pairs(DEFAULT_OPTIONS.languages) do
  if mod.extends and DEFAULT_OPTIONS.languages[mod.extends] then
    DEFAULT_OPTIONS.languages[name] = vim.tbl_deep_extend('keep', mod, DEFAULT_OPTIONS.languages[mod.extends])
  end
end

local OPTIONS = DEFAULT_OPTIONS

function M.get_config_for(key, fallback)
  return function(lang, type)
    local mod = DEFAULT_OPTIONS.languages[lang]
    return (mod and mod[key] and mod[key][type]) or fallback
  end
end

function M.get_option_for(key)
  return function(lang, type)
    local mod = OPTIONS.languages[lang]
    return mod and mod.options and mod.options[key] and mod.options[key][type]
  end
end

function M.setup(opts)
  if opts then
    OPTIONS = vim.tbl_deep_extend('force', DEFAULT_OPTIONS, opts)
  end
end

return M
