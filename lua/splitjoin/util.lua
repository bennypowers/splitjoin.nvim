local map = vim.tbl_map
local get_node_at_pos = vim.treesitter.get_node_at_pos

local M = {}

local OPTIONS = {}
local DEFAULTS = {}




-- INIT
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







--- OPERATION HELPERS
-- TODO: Remove these in favour of node helpers and default handlers
function M.get_joined(lang, type, sep, joined)
  if M.node_is_sep_first(lang, type) then
    return joined:gsub('%s*%'..sep, sep)
  else
    return joined:gsub(sep..'%s*', sep..' ')
  end
end

function M.add_sep(lang, type, base, indent, sep)
  base = base or ''
  if M.node_is_sep_first(lang, type) then
    return function(x)
      return (base..indent..sep..' '..vim.trim(x))
    end
  else
    return function(x)
      return (base..indent..vim.trim(x)..sep)
    end
  end
end






-- BUFFER ROW HELPERS
function M.buffer_get_line(bufnr, row)
  local line = unpack(vim.api.nvim_buf_get_lines(bufnr,
                                                 row,
                                                 row + 1,
                                                 true))
  return line
end

function M.buffer_join_row_below(row)
  local fst = M.buffer_get_line(0, row)
  local snd = M.buffer_get_line(0, row + 1)
  vim.api.nvim_buf_set_lines(0,
                             row,
                             row + 2,
                             true,
                             { fst:gsub('%s*$',' ') .. snd:gsub('^%s*', '') })
end














-- NODE HELPERS
function M.node_cursor_to_end(original_node)
  local row, col = original_node:range()
  local found, node = pcall(vim.treesitter.get_node_at_pos, 0, row, col, { ignore_injections = false })
  if found and node then
    local _, _, row_end, col_end = node:range()
    vim.api.nvim_win_set_cursor(0, { row_end + 1, col_end - 1 })
  end
end

function M.node_is_child_of(type, node)
  local current = node:parent()
  repeat
    if current and current:type() == type then
      return true
    end
    current = current:parent()
  until not current:parent()
  return false
end

function M.node_replace(node, replacement)
  local row, col, row_end, col_end = node:range()
  local base_indent = M.node_get_base_indent(node) or ''
  local starts_newline = replacement:match'^\n'
  local lines = M.split(replacement, '\n')
  for i, line in ipairs(lines) do
    if i > 1 then
      lines[i] = base_indent..line
    end
  end
  if starts_newline then table.insert(lines, 1, '') end
  vim.api.nvim_buf_set_text(0,
                            row,
                            col,
                            row_end,
                            col_end,
                            lines)
end

function M.node_get_base_indent(node)
  local row = node:range()
  return M.buffer_get_line(0, row):match'^%s+' or ''
end

function M.node_trim_line_end(node)
  local row = node:range()
  local trimmed = M.buffer_get_line(0, row):gsub('%s*$', '')
  vim.api.nvim_buf_set_lines(0,
                             row,
                             row + 1,
                             true,
                             { trimmed })
end

function M.node_join_to_previous_line(node)
  local row = node:range()
  M.buffer_join_row_below(row - 1)
end




-- STRING HELPERS
function M.is_lengthy(str)
  return str:len() > 0
end

function M.normalize_item(sep)
  return function(x)
    return vim.trim(x:gsub(sep, ''))
  end
end

function M.split(str, sep, opts)
  opts = vim.tbl_extend('keep', opts or {}, { plain = true, trimempty = true })
  return vim.split(str, sep, opts)
end

function M.dedupe(sep)
  return function(line)
    return not line:find('^%s*'..sep..'%s*$')
  end
end




-- CONFIG AND OPTS
local function get_config_for(key, fallback)
  return function(lang, type, op)
    local mod = DEFAULTS.languages[lang]
    -- TODO: make everything a node handler
    if key == 'handlers' then
      return (mod and mod[key] and mod[key][type] and mod[key][type][op]) or fallback
    else
      return (mod and mod[key] and mod[key][type]) or fallback
    end
  end
end

local function get_option_for(key)
  return function(lang, type)
    local mod = OPTIONS.languages[lang]
    return mod and mod.options and mod.options[key] and mod.options[key][type]
  end
end

M.node_is_sep_first = get_option_for('sep_first')
M.node_is_padded = get_option_for('pad')
M.node_is_no_trailing_comma = get_config_for('no_trailing_comma')

M.get_config_handlers = get_config_for('handlers')
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
