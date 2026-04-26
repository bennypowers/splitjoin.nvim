local M = {}

local is_in_node_range = vim.treesitter.is_in_node_range
local get_node_text = vim.treesitter.get_node_text

---@param bufnr number
---@param row number 1-indexed row
---@param col number 0-indexed column
---@return number[] {row, col} clamped to valid buffer position
function M.clamp(bufnr, row, col)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  row = math.max(1, math.min(row, line_count))
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''
  col = math.max(0, math.min(col, math.max(0, #line - 1)))
  return { row, col }
end

---@param bufnr number
---@param cursor number[] {row, col} 1-indexed row, 0-indexed col
---@param node TSNode the construct node before the handler runs
---@return table|nil hold context for restore_hold, or nil if cursor not in a child
function M.hold(bufnr, cursor, node)
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]
  local node_srow, node_scol = node:range()
  local node_type = node:type()

  local nws_total = 0
  for child in node:iter_children() do
    if get_node_text(child, bufnr):match('%S') then
      nws_total = nws_total + 1
    end
  end

  local nws_index = 0
  for child in node:iter_children() do
    local text = get_node_text(child, bufnr)
    if text:match('%S') then
      if is_in_node_range(child, cursor_row, cursor_col) then
        local csrow, cscol = child:range()
        local offset
        if cursor_row == csrow then
          offset = cursor_col - cscol
        else
          offset = cursor_col
        end
        return {
          nws_index = nws_index,
          is_last = (nws_index == nws_total - 1),
          offset = math.max(0, offset),
          node_srow = node_srow,
          node_scol = node_scol,
          node_type = node_type,
          cursor = cursor,
        }
      end
      nws_index = nws_index + 1
    end
  end
  return nil
end

---@param bufnr number
---@param ctx table hold context from M.hold()
---@return number[]|nil {row, col} restored cursor position, or nil if ctx is nil
function M.restore_hold(bufnr, ctx)
  if not ctx then
    return nil
  end

  local parser = vim.treesitter.get_parser(bufnr)
  if parser then parser:parse() end

  local new_node = vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { ctx.node_srow, ctx.node_scol },
    ignore_injections = false,
  })

  while new_node and new_node:type() ~= ctx.node_type do
    new_node = new_node:parent()
  end

  if not new_node then
    return M.clamp(bufnr, ctx.cursor[1], ctx.cursor[2])
  end

  local target_index = ctx.nws_index
  if ctx.is_last then
    local new_total = 0
    for child in new_node:iter_children() do
      if get_node_text(child, bufnr):match('%S') then
        new_total = new_total + 1
      end
    end
    target_index = new_total - 1
  end

  local nws_count = 0
  for child in new_node:iter_children() do
    local text = get_node_text(child, bufnr)
    if text:match('%S') then
      if nws_count == target_index then
        local csrow, cscol = child:range()
        local first_line = text:match('[^\n]*')
        local col = math.min(cscol + ctx.offset, cscol + #first_line - 1)
        return { csrow + 1, math.max(0, col) }
      end
      nws_count = nws_count + 1
    end
  end

  return M.clamp(bufnr, ctx.cursor[1], ctx.cursor[2])
end

return M
