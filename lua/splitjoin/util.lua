local M = {}

local OPTIONS = {}
local DEFAULTS = {}

local function get_config_for(key, fallback)
  return function(lang, type)
    local mod = DEFAULTS.languages[lang]
    return (mod and mod[key] and mod[key][type]) or fallback
  end
end

local function get_option_for(key)
  return function(lang, type)
    local mod = OPTIONS.languages[lang]
    return mod and mod.options and mod.options[key] and mod.options[key][type]
  end
end

function M.init(overrides)
  for name, mod in pairs(overrides.languages) do
    if mod.extends and overrides.languages[mod.extends] then
      overrides.languages[name] = vim.tbl_deep_extend('keep', mod, overrides.languages[mod.extends])
    end
  end

  DEFAULTS = overrides or {}
  OPTIONS = overrides or {}
end

function M.setup(opts)
  if opts then
    OPTIONS = vim.tbl_deep_extend('force', DEFAULTS, opts)
  end
end

function M.identity(x)
  return x
end

--- trim first line
function M.trim_end(op, node, bufnr, winnr, row, col)
  local first_line = unpack(vim.api.nvim_buf_get_lines(bufnr,
                                                       row,
                                                       row + 1,
                                                       true))

  local trimmed = first_line:gsub('%s+$', '')
  vim.api.nvim_buf_set_lines(bufnr,
                             row,
                             row + 1,
                             true,
                             { trimmed })
  if op == 'join' then
    vim.cmd.norm(row..'GJ')
    M.jump_to_node_end_at(op, node, bufnr, winnr, row, col + 1, 0, trimmed:len())
  else
    M.jump_to_node_end_at(op, node, bufnr, winnr, row + 1, col, 1, -1)
  end
end

local get_node_at_pos = vim.treesitter.get_node_at_pos

function M.jump_to_node_end_at(op, node, bufnr, winnr, row, col, row_offset, col_offset)
  local found, node = pcall(get_node_at_pos, bufnr,
                                             row,
                                             col,
                                             { ignore_injections = false })
  if found then
    local _, _, end_row, end_col = node:range()

    vim.api.nvim_win_set_cursor(winnr, {
      end_row + (row_offset or 1),
      end_col + (col_offset or -1),
    })
  end
end

M.is_sep_first = get_option_for('sep_first')
M.is_padded = get_option_for('pad')
M.is_no_trailing_comma = get_config_for('no_trailing_comma')
M.get_config_after = get_config_for('after', M.jump_to_node_end_at)
M.get_config_before = get_config_for('before', M.identity)
M.get_config_separators = get_config_for('separators')
M.get_config_indent = get_config_for('default_indent')

function M.get_config_surrounds(lang, type, source)
  local surrounds = get_config_for('surround')(lang, type)
  if not surrounds then
    return false, false
  elseif surrounds == true then
    return source:sub(1, 1), source:sub(-1)
  else
    return unpack(surrounds)
  end
end

return M
