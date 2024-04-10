local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'

local JSDoc = {}

function JSDoc.split_jsdoc_description(node, options)
  local text = Node.get_text(node)
  if String.is_multiline(text) then return end
  text = text:gsub([[%*$]], '')
  local indent = options.default_indent or ' '
  local base_indent = Node.get_base_indent(node)
  local append, get = String.append('')
  append(
    '\n',
    indent,
    base_indent,
    '* ',
    text,
    '\n',
    ' *'
  )
  local row, col = unpack(vim.api.nvim_win_get_cursor(0));
  Node.replace(node, get())
  Node.trim_line_end(node)
  Node.trim_line_end(node, 1)
  vim.api.nvim_win_set_cursor(0, { row + 1, col - 1 })
end

function JSDoc.join_jsdoc_description(node, options)
  local text = Node.get_text(node)
  if String.is_multiline(text) then return end
  local nrow, ncol = node:range()
  local comment = vim.treesitter.get_node { pos = { nrow, ncol - 1 } }
  if comment and not String.is_singleline(Node.get_text(comment)) then
    local row, col = unpack(vim.api.nvim_win_get_cursor(0));
    Node.replace(comment, '/** ' .. text .. ' */')
    Node.goto_node(comment)
  vim.api.nvim_win_set_cursor(0, { row - 1, col + 1 })
  end
end

return JSDoc
