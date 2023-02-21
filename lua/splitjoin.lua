local U = require'splitjoin.util'

local flatten = vim.tbl_flatten
local filter = vim.tbl_filter
local map = vim.tbl_map

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

local function get_node(bufnr, winnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  -- TODO: cache a reference per bufnr
  local tsparser = vim.treesitter.get_parser(bufnr)
  local tstree = tsparser:parse()[1]
  local langtree = tsparser:language_for_range { row, col, row, col };
  local lang = langtree:lang()
  local query = vim.treesitter.get_query(lang, 'splitjoin')
  local nodes = {}
  if query then
    for _, node, _ in query:iter_captures(tstree:root(), bufnr, row - 1, row) do
      if vim.treesitter.is_in_node_range(node, row - 1, col) then
        table.insert(nodes, node)
      end
    end
  end

  local node = nodes[#nodes]
  if node then
    local getter = U.get_config_operative_node(lang, node:type())
    if getter then
      node = getter(node) or node
    end
    local start_row, start_col, end_row, end_col = node:range()
    local range = { start_row, start_col, end_row, end_col }
    local source = vim.treesitter.get_node_text(node, bufnr)
    return node, range, source, lang
  end
end

---@return string[]
local function join(string, lang, type, sep, open, close, indent, base_indent)
  local inner = string
  if open and close then inner = string:sub(2, -2) end
  local lines = filter(U.is_lengthy, map(U.normalize_item(sep), U.split(inner, '\n')))
  local list = U.get_joined(lang, type, sep, table.concat(lines, sep))
  local padding = U.node_is_padded(lang, type) and ' ' or ''
  return { (open or '') .. padding .. vim.trim(list) .. padding .. (close or '') }
end

---@return string[]
local function split(string, lang, type, sep, open, close, indent, base_indent)
  local inner = string
  if open and close then inner = string:sub(2, -2) end
  local lines = map(U.add_sep(lang, type, base_indent, indent, sep), U.split(inner, sep))
  if U.node_is_no_trailing_comma(lang, type) then
    lines[#lines] = lines[#lines]:gsub(sep, '')
  end
  return filter(U.dedupe(sep), flatten {
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
      if op == 'join' and not source:find'\n' then return end
      local type = node:type()
      local after = U.get_config_after(lang, type)
      local before = U.get_config_before(lang, type)
      local indent = U.get_config_indent(lang, type) or '  '
      local sep = U.get_config_separators(lang, type) or ','
      local open, close = U.get_config_surrounds(lang, type, source)
      local row, col, end_row, end_col = unpack(range)
      local base_indent = U.get_line(bufnr, row):match'^%s+' or ''

      local lines = flatten(operation(source,
                                      lang,
                                      type,
                                      sep,
                                      open,
                                      close,
                                      indent,
                                      base_indent))

      local final = before(op,
                           node,
                           base_indent,
                           lines) or lines

      vim.api.nvim_buf_set_text(bufnr,
                                row,
                                col,
                                end_row,
                                end_col,
                                final)

      after(op, node, bufnr, winnr, row, col)

      if op == 'split' and base_indent:len() > 0 and close then
        local last_row = row + #final - 1
        vim.api.nvim_buf_set_lines(bufnr, last_row, last_row + 1, false, {
          base_indent .. U.get_line(bufnr, last_row)
        })
      end
    end
  end
end

M.join = splitjoin(join)
M.split = splitjoin(split)

return M;
