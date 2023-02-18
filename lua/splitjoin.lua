local M = {}

local default_indent

function M.setup(opts)
  opts = opts or {}
  default_indent = opts.default_indent or '  '
end

local function normalize(x)
  return vim.split(x, '\n', { plain = true, trimempty = true })
end

local function dedupe(sep)
  return function(line)
    return not line:find('^%s*'..sep..'%s*$')
  end
end

local trailing_comma = {
  lua = {
    parameters = true,
    arguments = true,
  }
}

local function is_no_trailing_comma(lang, type)
  local t = trailing_comma[lang]
  return (not (not (t and t[type])))
end

local no_pad = {
  lua = {
    parameters = true,
    arguments = true,
  },
  javascript = {
    formal_parameters = true,
    arguments = true,
  },
}

local function is_no_pad(lang, type)
  local t = no_pad[lang]
  return (not (not (t and t[type])))
end

local function iter_caps(bufnr, winnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  -- TODO: cache a reference per bufnr
  local tsparser = vim.treesitter.get_parser(bufnr)
  local tstree = tsparser:parse()[1]
  local langtree = tsparser:language_for_range{ row, col, row, col };
  local lang = langtree:lang()

  local query = vim.treesitter.get_query(lang, 'splitjoin')

  if not query then return end

  local i = 0
  return function()
    i = i + 1
    if i > 1 then return nil end
    for _, node, _ in query:iter_captures(tstree:root(), bufnr, row - 1, row) do
      if vim.treesitter.is_in_node_range(node, row - 1, col) then
        local start_row, start_col, end_row, end_col = node:range()
        local range = { start_row, start_col, end_row, end_col }
        local source = vim.treesitter.get_node_text(node, bufnr)
        return node, range, source, lang
      end
    end
    return nil
  end
end

---@return string[]
local function join_comma_line_separated_text(string, lang, type, sep, open, close, indent)
  local joined = string:gsub('%s+', ' ')
  local inner = joined:sub(2, -2)
  local list = inner:gsub('^%s+', ''):gsub(sep..'%s+$', '')
  local padding = ' '
  if is_no_pad(lang, type) then
    padding = ''
  end
  return { open .. padding .. vim.trim(list) .. padding .. close }
end

---@return string[]
local function split_comma_separated_text(string, lang, type, sep, open, close, indent)
  local inner = string:sub(2, -2)

  local separated = vim.split(inner, sep, { plain = false, trimempty = true })

  local lines = vim.tbl_map(function(x)
    return (indent..vim.trim(x)..sep)
  end, separated)

  if is_no_trailing_comma(lang, type) then
    lines[#lines] = lines[#lines]:gsub(sep, '')
  end

  return vim.tbl_filter(dedupe(sep), vim.tbl_flatten {
    open,
    lines,
    close,
  })
end

local function splitjoin(operation)
  return function(bufnr, winnr)
    bufnr = bufnr or 0
    winnr = winnr or 0
    for node, range, source, lang in iter_caps(bufnr, winnr) do
      local sep = ','
      local open = source:sub(1, 1)
      local close = source:sub(-1)
      local indent = default_indent
      local start_row, start_col, end_row, end_col = unpack(range)
      local replacements = vim.tbl_flatten(vim.tbl_map(normalize, operation(source,
                                                                            lang,
                                                                            node:type(),
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

      local new_node = vim.treesitter.get_node_at_pos(bufnr,
                                                      start_row,
                                                      start_col,
                                                      { ignore_injections = false })
      local _, _, new_end_row, new_end_col = new_node:range()
      vim.api.nvim_win_set_cursor(winnr, { new_end_row + 1, new_end_col - 1 })
    end
  end
end

M.join = splitjoin(join_comma_line_separated_text)
M.split = splitjoin(split_comma_separated_text)

return M;
