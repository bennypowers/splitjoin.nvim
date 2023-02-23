local Buffer = require'splitjoin.util.buffer'
local String = require'splitjoin.util.string'

local Node = {}

-- NODE HELPERS
function Node.cursor_to_end(original_node)
  local row, col = original_node:range()
  local found, node = pcall(vim.treesitter.get_node_at_pos, 0, row, col, { ignore_injections = false })
  if found and node then
    local _, _, row_end, col_end = node:range()
    vim.api.nvim_win_set_cursor(0, { row_end + 1, col_end - 1 })
  end
end

function Node.is_child_of(type, node)
  local current = node:parent()
  repeat
    if current and current:type() == type then
      return true
    end
    current = current:parent()
  until not current:parent()
  return false
end

function Node.replace(node, replacement)
  local row, col, row_end, col_end = node:range()
  local base_indent = Node.get_base_indent(node) or ''
  local starts_newline = replacement:match'^\n'
  local lines = String.split(replacement, '\n')
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

function Node.get_base_indent(node)
  local row = node:range()
  return Buffer.get_line(0, row):match'^%s+' or ''
end

function Node.trim_line_end(node)
  local row = node:range()
  local trimmed = Buffer.get_line(0, row):gsub('%s*$', '')
  vim.api.nvim_buf_set_lines(0,
                             row,
                             row + 1,
                             true,
                             { trimmed })
end

function Node.join_to_previous_line(node)
  local row = node:range()
  Buffer.join_row_below(row - 1)
end

return Node
