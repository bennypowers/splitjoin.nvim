local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'

local Lua = {}

function Lua.split_function(node, options)
  local indent = options.default_indent or '  '
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'local' then
      append(Node.get_text(child), ' ')
    elseif type == 'function' then
      append('function')
      if node:type() == 'function_declaration' then
        append(' ')
      end
    elseif type == 'parameters' then
      append(Node.get_text(child), '\n')
    elseif type == 'block' then
      append(indent, Node.get_text(child))
    elseif type == 'end' then
      append('\n', 'end')
    else
      local line = Node.get_text(child)
      append(line)
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function Lua.join_function(node, options)
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'local' or type == 'parameters' then
      append(Node.get_text(child), ' ')
    elseif type == 'function' then
      append('function')
      if node:type() == 'function_declaration' then append(' ') end
    elseif type == 'block' then
      append(Node.get_text(child), ' ')
    elseif type == 'end' then
      append('end')
    else
      append(Node.get_text(child))
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function Lua.split_if(node, options)
  local indent = options.default_indent or '  '
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'if' then
      append('if ', Node.get_text(child:next_sibling()), ' then\n')
    elseif type == 'end' then
      append('\nend')
    elseif type == 'block' then
      append(indent, vim.trim(Node.get_text(child)))
    elseif type == 'elseif_statement' or type == 'else_statement' then
      for grandchild in child:iter_children() do
        local gctype = grandchild:type()
        if gctype == 'elseif' then
          append('\nelseif ', Node.get_text(grandchild:next_sibling()), ' then\n')
        elseif gctype == 'else' then
          append('\nelse\n')
        elseif gctype == 'block' then
          append(indent, vim.trim(Node.get_text(grandchild)))
        end
      end
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function Lua.join_if(node)
  local replacement = ''
  local function append(s, t) replacement = replacement .. s .. (t or '') end
  for child in node:iter_children() do
    local type = child:type()
    if type == 'if' then
      append('if '..Node.get_text(child:next_sibling())..' then ')
    elseif type == 'block' then
      append(Node.get_text(child), ' ')
    elseif type == 'elseif_statement' or type == 'else_statement' then
      for grandchild in child:iter_children() do
        local gctype = grandchild:type()
        if gctype == 'elseif' then
          append('elseif '..Node.get_text(grandchild:next_sibling())..' then', ' ')
        elseif gctype == 'else' then
          append('else', ' ')
        elseif gctype == 'block' then
          append(vim.trim(Node.get_text(grandchild)), ' ')
        end
      end
    elseif type == 'end' then
      append('end')
    end
  end
  Node.replace(node, replacement)
  Node.goto_node(node)
end

return Lua
