local Node = require'splitjoin.util.node'

local Nix = {}

function Nix.split_list(node, options)
  local indent = options.default_indent or '  '
  local items = {}

  for child in node:iter_children() do
    local t = child:type()
    if t ~= '[' and t ~= ']' then
      table.insert(items, vim.trim(Node.get_text(child)))
    end
  end

  if #items < 2 then return end

  local lines = { '[\n' }
  for _, item in ipairs(items) do
    table.insert(lines, indent .. item .. '\n')
  end
  table.insert(lines, ']')

  Node.replace(node, table.concat(lines, ''))
  Node.goto_node(node)
end

function Nix.join_list(node)
  local text = Node.get_text(node)
  if not text:find('\n') then return end

  local items = {}
  for child in node:iter_children() do
    local t = child:type()
    if t ~= '[' and t ~= ']' then
      table.insert(items, vim.trim(Node.get_text(child)))
    end
  end

  Node.replace(node, '[ ' .. table.concat(items, ' ') .. ' ]')
  Node.goto_node(node)
end

return Nix
