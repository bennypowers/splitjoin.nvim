local M = {}

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

return M
