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

  local nws_children = {}
  local found_index = nil
  local found_offset = nil

  for child in node:iter_children() do
    if get_node_text(child, bufnr):match('%S') then
      local idx = #nws_children
      if not found_index and is_in_node_range(child, cursor_row, cursor_col) then
        local csrow, cscol = child:range()
        found_index = idx
        found_offset = math.max(0, cursor_col - cscol)
      end
      nws_children[idx + 1] = true
    end
  end

  if not found_index then
    return nil
  end

  return {
    nws_index = found_index,
    is_last = (found_index == #nws_children - 1),
    offset = found_offset,
    node_srow = node_srow,
    node_scol = node_scol,
    node_type = node_type,
    cursor = cursor,
  }
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

  while new_node do
    if new_node:type() == ctx.node_type then
      local sr, sc = new_node:range()
      if sr == ctx.node_srow and sc == ctx.node_scol then
        break
      end
    end
    new_node = new_node:parent()
  end

  if not new_node then
    return M.clamp(bufnr, ctx.cursor[1], ctx.cursor[2])
  end

  local nws = {}
  for child in new_node:iter_children() do
    if get_node_text(child, bufnr):match('%S') then
      nws[#nws + 1] = child
    end
  end

  local target = ctx.is_last and nws[#nws] or nws[ctx.nws_index + 1]

  if not target then
    return M.clamp(bufnr, ctx.cursor[1], ctx.cursor[2])
  end

  local csrow, cscol = target:range()
  local first_line = get_node_text(target, bufnr):match('[^\n]*')
  local max_offset = math.max(0, #first_line - 1)
  local col = cscol + math.min(ctx.offset, max_offset)
  return { csrow + 1, math.max(0, col) }
end

return M
