local M = {}

local DEFAULT_OPTIONS = {
  default_indent = '  ',
  no_trailing_comma = {
    lua = {
      parameters = true,
      arguments = true,
      variable_list = true,
    },
  },
  pad = {
    lua = {
      table_constructor = true,
    },
    javascript = {
      object = true,
    },
    css = {
      block = true,
    },
  },
  surround = {
    lua = {
      parameters = true,
      arguments = true,
      table_constructor = true,
    },
    javascript = {
      object = true,
      array = true,
      arguments = true,
      formal_parameters = true,
    },
    typescript = {
      object = true,
      array = true,
      arguments = true,
      formal_parameters = true,
    },
    css = {
      block = true,
    },
  },
  separators = {
    css = {
      block = ';',
    },
  },
}

local OPTIONS = DEFAULT_OPTIONS

function M.setup(opts)
  if opts then
    OPTIONS = vim.tbl_deep_extend('force', DEFAULT_OPTIONS, opts)
  end
end

local function normalize(x)
  return vim.split(x, '\n', { plain = true, trimempty = true })
end

local function dedupe(sep)
  return function(line)
    return not line:find('^%s*'..sep..'%s*$')
  end
end

local function get_config_for(config_table)
  return function(lang, type)
    return config_table and config_table[lang] and config_table[lang][type]
  end
end

local is_no_trailing_comma = get_config_for(OPTIONS.no_trailing_comma)
local is_padded = get_config_for(OPTIONS.pad)
local is_surround = get_config_for(OPTIONS.surround)
local separators = get_config_for(OPTIONS.separators)

local function get_node(bufnr, winnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  -- TODO: cache a reference per bufnr
  local tsparser = vim.treesitter.get_parser(bufnr)
  local tstree = tsparser:parse()[1]
  local langtree = tsparser:language_for_range{ row, col, row, col };
  local lang = langtree:lang()

  local query = vim.treesitter.get_query(lang, 'splitjoin')

  if not query then return end

  for _, node, _ in query:iter_captures(tstree:root(), bufnr, row - 1, row) do
    if vim.treesitter.is_in_node_range(node, row - 1, col) then
      local start_row, start_col, end_row, end_col = node:range()
      local range = { start_row, start_col, end_row, end_col }
      local source = vim.treesitter.get_node_text(node, bufnr)
      return node, range, source, lang
    end
  end
end

---@return string[]
local function join(string, lang, type, sep, open, close, indent)
  local inner = string
  if open and close then
    inner = string:sub(2, -2)
  end
  local joined = inner:gsub('%s*', '')
  local list = joined:gsub(sep..'%s*', sep..' ')
  local padding = is_padded(lang, type) and ' ' or ''
  return { (open or '') .. padding .. vim.trim(list) .. padding .. (close or '') }
end

---@return string[]
local function split(string, lang, type, sep, open, close, indent)
  local inner = string
  if open and close then
    inner = string:sub(2, -2)
  end
  local separated = vim.split(inner, sep, { plain = false, trimempty = true })
  local lines = vim.tbl_map(function(x)
    local prefix = indent
    if not open and not close then
      prefix = ''
    end
    return (prefix..vim.trim(x)..sep)
  end, separated)
  if is_no_trailing_comma(lang, type) then
    lines[#lines] = lines[#lines]:gsub(sep, '')
  end
  return vim.tbl_filter(dedupe(sep), vim.tbl_flatten {
    open or '',
    lines,
    close or nil,
  })
end

local function jump_to_node_end_at(bufnr, winnr, row, col)
  local node = vim.treesitter.get_node_at_pos(bufnr,
                                              row,
                                              col,
                                              { ignore_injections = false })
  local _, _, end_row, end_col = node:range()
  vim.api.nvim_win_set_cursor(winnr, { end_row + 1, end_col - 1 })
end

local function splitjoin(operation)
  return function(bufnr, winnr)
    bufnr = bufnr or 0
    winnr = winnr or 0
    local node, range, source, lang = get_node(bufnr, winnr)
    if not (node and range and source and lang) then return end
    local type = node:type()
    local sep = separators(lang, type) or ','
    local open = source:sub(1, 1)
    local close = source:sub(-1)
    if not is_surround(lang, type) then
      open = false
      close = false
    end
    local indent = OPTIONS.default_indent
    local start_row, start_col, end_row, end_col = unpack(range)
    local replacements = vim.tbl_flatten(vim.tbl_map(normalize, operation(source,
                                                                          lang,
                                                                          type,
                                                                          sep,
                                                                          open,
                                                                          close,
                                                                          indent)))
    vim.api.nvim_buf_set_text(bufnr,
                              start_row,
                              start_col,
                              end_row,
                              end_col,
                              replacements)

    jump_to_node_end_at(bufnr, winnr, start_row, start_col)
  end
end

M.join = splitjoin(join)
M.split = splitjoin(split)

return M;
