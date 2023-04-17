local Buffer = require'splitjoin.util.buffer'
local String = require'splitjoin.util.string'

local get_node_text = vim.treesitter.get_node_text

local Node = {}

-- NODE HELPERS

---@param node TSNode
---@return string
function Node.get_text(node)
  return get_node_text(node, 0)
end


---@param node TSNode
---@param type string type name
---@return boolean
function Node.next_sibling_is(node, type)
  local next = node:next_sibling() or false
  return next and next:type() == type
end

local parsers = {}

function Node.cache_parser(node, parser)
  parsers[node] = parser
end

function Node.refresh(node)
  local parser = parsers[node]
  if parser then
    parser:parse()
  end
end

function Node.goto_node(node, place, col_offset)
  place = place or 'end'
  col_offset = col_offset or 0
  if node then
    local srow, scol, erow, ecol = node:range()
    local pos = { srow + 1, scol - 1 + col_offset }
    if place == 'end' then
      pos = { erow + 1, ecol - 1 + col_offset }
    end
    local success = pcall(vim.api.nvim_win_set_cursor, 0, pos)
    if not success then
      require'nvim-treesitter.ts_utils'.goto_node(node, place == 'end')
    end
  end
end

function Node.get_index(node)
  local index = 0
  local parent = node:parent()
  for child in parent:iter_children() do
    if child == node then
      break
    else
      index = index + 1
    end
    if parent:child(index) ~= node then
      index = -1
    end
  end
  return index
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

--- default, child-aware splitter
---@param node TSNode
---@param options SplitjoinLanguageOptions
function Node.split(node, options)
  local indent = options.default_indent or '  '
  local sep = options.separator or ','
  local separator_is_node = options.separator_is_node or true
  local open, close = unpack(options.surround or {})
  local lines = {}

  for child in node:iter_children() do
    local type = child:type()
    if     type == open then  table.insert(lines, open..'\n')
    elseif type == sep then   table.insert(lines, (separator_is_node and '\n' or ''))
    elseif type == close then table.insert(lines, close)
    else
      local text = vim.trim(Node.get_text(child)):gsub(sep..'$', '')
      local line = indent .. text .. sep
      table.insert(lines, line..(separator_is_node and '\n' or ''))
    end
  end

  lines = String.filter_only_whitespace(lines)

  if options.trailing_separator == false then
    local index = #lines
    if close and #close > 0 then index = index - 1 end
    lines[index] = lines[index]:gsub(sep..'%s$', '\n')
  end

  Node.replace(node, table.concat(lines, ''))
  Node.goto_node(node)
end

function Node.join(node, options)
  local replacement = ''
  local sep = options.separator or ','
  local open, close = unpack(options.surround or {})
  local padding = options.padding or ''

  local function append(string, suffix)
    suffix = suffix or ''
    replacement = replacement .. string .. suffix
  end

  for child in node:iter_children() do
    local type = child:type()
    if     type == open then  append(type, padding)
    elseif type == close then append(padding, type)
    elseif type == sep then
      if Node.next_sibling_is(child, close) then
        append('', '')
      else
        append(sep, ' ') -- TODO: inner vs outer padding
      end
    elseif options.separator_is_node == false then
      local text = vim.trim(Node.get_text(child)):gsub(sep..'$', '')
      if Node.next_sibling_is(child, close) then
        append(text)
      else
        append(text..sep, ' ') -- TODO: inner vs outer padding
      end
    else
      append(vim.trim(Node.get_text(child)))
    end
  end
  Node.replace(node, replacement)
  Node.goto_node(node)
end

return Node
