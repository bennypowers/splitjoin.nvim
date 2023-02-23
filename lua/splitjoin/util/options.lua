--- Options functions
local Options = {}

local DEFAULTS = {
  languages = {
    lua = require'splitjoin.languages.lua.defaults',
    ecmascript = require'splitjoin.languages.ecmascript.defaults',
    javascript = require'splitjoin.languages.javascript.defaults',
    typescript = require'splitjoin.languages.typescript.defaults',
    css = require'splitjoin.languages.css.defaults',
  },
}

for name, mod in pairs(DEFAULTS.languages) do
  if mod.extends and DEFAULTS.languages[mod.extends] then
    DEFAULTS.languages[name] = vim.tbl_deep_extend('keep', mod, DEFAULTS.languages[mod.extends])
  end
end

local OPTIONS = DEFAULTS

function Options.setup(opts)
  opts = opts or {}
  for lang, mod in pairs(OPTIONS.languages) do
    local parent = {}
    local options = {}
    local yes, o
    yes, o = pcall(require, 'splitjoin.languages.'..lang..'.options')
    if yes then options = o end
    yes, o = pcall(require, 'splitjoin.languages.' .. (mod.extends or '.') ..'.options')
    if yes then parent = o end
    OPTIONS.languages[lang] = vim.tbl_deep_extend('keep', mod, parent, options)
  end
  OPTIONS = vim.tbl_deep_extend('keep', DEFAULTS, opts)
end

-- CONFIG AND OPTS
function Options.get_options_for(lang, type)
  local _, options = pcall(function() return OPTIONS.languages[lang] end)
  options = options or {}
  options.nodes = options.nodes or {}
  return options.nodes[type] or {}
end

Options.setup()

return Options
