local U = require'splitjoin.util'

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

U.init(DEFAULT_OPTIONS)

function M.setup(opts) U.setup(opts) end

local function dedupe(sep)
  return function(line)
    return not line:find('^%s*'..sep..'%s*$')
  end
end


local function add_sep_before(indent, sep)
  return function(x)
    return (indent..sep..' '..vim.trim(x))
  end
end

local function add_sep_after(indent, sep)
  return function(x)
    return (indent..vim.trim(x)..sep)
  end
end

local function get_node(bufnr, winnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  -- TODO: cache a reference per bufnr
  local tsparser = vim.treesitter.get_parser(bufnr)
  local tstree = tsparser:parse()[1]
  local langtree = tsparser:language_for_range { row, col, row, col };
  local lang = langtree:lang()
  local query = vim.treesitter.get_query(lang, 'splitjoin')
  if query then
    for _, node, _ in query:iter_captures(tstree:root(), bufnr, row - 1, row) do
      if vim.treesitter.is_in_node_range(node, row - 1, col) then
        local start_row, start_col, end_row, end_col = node:range()
        local range = { start_row, start_col, end_row, end_col }
        local source = vim.treesitter.get_node_text(node, bufnr)
        return node, range, source, lang
      end
    end
  end
end

---@return string[]
local function join(string, lang, type, sep, open, close, indent)
  local inner = string

  if open and close then
    inner = string:sub(2, -2)
  end

  local lines = vim.tbl_map(function(x)
    return vim.trim(x:gsub(sep, ''))
  end, vim.split(inner, '\n', { plain = true, trimempty = true }))

  local joined = table.concat(lines, sep)

  local list-- = joined:gsub(sep..'%s*', sep..' ')

  if U.is_sep_first(lang, type) then
    list = joined:gsub('%s*%'..sep, sep)
  else
    list = joined:gsub(sep..'%s*', sep..' ')
  end

  local padding = U.is_padded(lang, type) and ' ' or ''

  return { (open or '') .. padding .. vim.trim(list) .. padding .. (close or '') }
end

---@return string[]
local function split(string, lang, type, sep, open, close, indent)
  local inner = string

  local sep_first = U.is_sep_first(lang, type)

  if open and close then
    inner = string:sub(2, -2)
  end

  local separated = vim.split(inner, sep, { plain = false, trimempty = true })

  local adder = sep_first and add_sep_before(indent, sep) or add_sep_after(indent, sep)

  local lines = vim.tbl_map(adder, separated)

  if U.is_no_trailing_comma(lang, type) then
    lines[#lines] = lines[#lines]:gsub(sep, '')
  end

  return vim.tbl_filter(dedupe(sep), vim.tbl_flatten {
    open or {},
    lines,
    close or {},
  })
end

local function splitjoin(operation)
  local op = operation == join and 'join' or 'split'
  return function(bufnr, winnr)
    bufnr = bufnr or 0
    winnr = winnr or 0
    local node, range, source, lang = get_node(bufnr, winnr)
    if node then
      local type = node:type()
      local after = U.get_config_after(lang, type)
      local before = U.get_config_before(lang, type)
      local indent = U.get_config_indent(lang, type) or '  '
      local sep = U.get_config_separators(lang, type) or ','
      local open, close = U.get_config_surrounds(lang, type, source)
      local row, col, end_row, end_col = unpack(range)

      local lines = vim.tbl_flatten(operation(source,
                                              lang,
                                              type,
                                              sep,
                                              open,
                                              close,
                                              indent))

      vim.api.nvim_buf_set_text(bufnr,
                                row,
                                col,
                                end_row,
                                end_col,
                                before(lines, node, op))

      after(op, node, bufnr, winnr, row, col)
    end
  end
end

M.join = splitjoin(join)
M.split = splitjoin(split)

return M;
