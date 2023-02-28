local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'
local get_text = Node.get_text

local Lua = {}

function Lua.split_function(node, options)
  local indent = options.default_indent or '  '
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'local' then append(get_text(child), ' ')
    elseif type == 'parameters' then append(get_text(child), '\n')
    elseif type == 'block' then append(indent, get_text(child))
    elseif type == 'end' then append('\n', 'end')
    elseif type == 'function' then
      append('function')
      if node:type() == 'function_declaration' then
        append(' ')
      end
    else append(get_text(child))
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function Lua.join_function(node, options)
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'local' or type == 'parameters' then append(get_text(child), ' ')
    elseif type == 'function' then
      append('function')
      if node:type() == 'function_declaration' then append(' ') end
    elseif type == 'block' then append(get_text(child), ' ')
    elseif type == 'end' then append('end')
    else append(get_text(child))
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
    if type == 'if' then append('if ', get_text(child:next_sibling()), ' then\n')
    elseif type == 'end' then append('\nend')
    elseif type == 'block' then append(indent, vim.trim(get_text(child)))
    elseif type == 'elseif_statement' or type == 'else_statement' then
      for gc in child:iter_children() do
        local  gctype = gc:type()
        if     gctype == 'elseif' then append('\nelseif ', get_text(gc:next_sibling()), ' then\n')
        elseif gctype == 'else'   then append('\nelse\n')
        elseif gctype == 'block'  then append(indent, vim.trim(get_text(gc)))
        end
      end
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function Lua.join_if(node)
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'if' then append('if ', get_text(child:next_sibling()), ' then ')
    elseif type == 'end' then append('end')
    elseif type == 'block' then append(get_text(child), ' ')
    elseif type == 'elseif_statement' or type == 'else_statement' then
      for gc in child:iter_children() do
        local  gctype = gc:type()
        if     gctype == 'elseif' then append('elseif ', get_text(gc:next_sibling()), ' then ')
        elseif gctype == 'else'   then append('else', ' ')
        elseif gctype == 'block'  then append(vim.trim(get_text(gc)), ' ')
        end
      end
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

return Lua
