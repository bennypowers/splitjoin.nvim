local Node = require'splitjoin.util.node'

local Yaml = {}

local function all_scalars(node)
  return not Node.find_descendant(node, function(n)
    if n == node then return false end
    local t = n:type()
    return t == 'flow_sequence' or t == 'flow_mapping'
  end)
end

local function in_flow_context(node)
  local parent = node:parent()
  while parent do
    local t = parent:type()
    if t == 'flow_sequence' or t == 'flow_mapping' then
      return true
    end
    parent = parent:parent()
  end
  return false
end

function Yaml.split_flow_sequence(node, options)
  if not all_scalars(node) or in_flow_context(node) then
    return Node.split(node, options)
  end

  local indent = options.default_indent or '  '
  local items = {}
  for child in node:iter_children() do
    local t = child:type()
    if t ~= '[' and t ~= ']' and t ~= ',' then
      table.insert(items, vim.trim(Node.get_text(child)))
    end
  end

  if #items == 0 then return end

  local row, col, row_end, col_end = node:range()
  local base_indent = Node.get_base_indent(node) or ''
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
  local before = line:sub(1, col)

  local lines = {}
  local start_col = col

  if before:match(':%s*$') then
    local content_len = #before:match('^(.-)%s*$')
    start_col = content_len
    table.insert(lines, '')
    for _, item in ipairs(items) do
      table.insert(lines, base_indent .. indent .. '- ' .. item)
    end
  else
    for _, item in ipairs(items) do
      table.insert(lines, base_indent .. '- ' .. item)
    end
    start_col = 0
  end

  vim.api.nvim_buf_set_text(0, row, start_col, row_end, col_end, lines)
  if start_col == 0 then
    pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, #base_indent })
  else
    pcall(vim.api.nvim_win_set_cursor, 0, { row + 2, #(base_indent .. indent) })
  end
end

function Yaml.join_block_sequence(node, options)
  local items = {}
  for child in node:iter_children() do
    if child:type() == 'block_sequence_item' then
      for grandchild in child:iter_children() do
        if grandchild:type() ~= '-' then
          local text = vim.trim(Node.get_text(grandchild))
          if text ~= '' then
            table.insert(items, text)
          end
        end
      end
    end
  end

  if #items == 0 then return end

  local row, col, row_end, col_end = node:range()
  local replacement = '[' .. table.concat(items, ', ') .. ']'

  local line_count = vim.api.nvim_buf_line_count(0)
  if row_end >= line_count then
    row_end = line_count - 1
    col_end = #vim.api.nvim_buf_get_lines(0, row_end, row_end + 1, false)[1]
  end

  if row > 0 then
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local colon_pos = prev_line:find(':%s*$')
    if colon_pos then
      vim.api.nvim_buf_set_text(0, row - 1, colon_pos, row_end, col_end, { ' ' .. replacement })
      pcall(vim.api.nvim_win_set_cursor, 0, { row, colon_pos + 1 })
      return
    end
  end

  vim.api.nvim_buf_set_text(0, row, col, row_end, col_end, { replacement })
  pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
end

return Yaml
