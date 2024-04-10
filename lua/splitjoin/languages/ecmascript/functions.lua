local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'
local get_text = Node.get_text

local ECMAScript = {}

function ECMAScript.split_function(node, options)
  local indent = options.default_indent or '  '
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'formal_parameters' then append(get_text(child))
    elseif type == 'statement_block' then append(' {\n',indent, get_text(child):gsub('^{%s*', ''):gsub('%s*}$', ''), '\n}')
    elseif vim.startswith(type, 'function') then
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

function ECMAScript.split_arrow_function(node, options)
  local indent = options.default_indent or '  '
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'formal_parameters' or type == 'identifier' then
      append(get_text(child))
    elseif type == '=>' then
      local next = child:next_sibling()
      if next:type() == 'statement_block' then
        append(' => ')
        for gc in next:iter_children() do
          local gctype = gc:type()
          if gctype == '{' then append('{', '\n')
          elseif gctype == '}' then append('}')
          else append(indent, get_text(gc), '\n')
          end
        end
      else
        append(' => {\n', indent, 'return ', get_text(next), ';\n}')
      end
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function ECMAScript.join_function(node, options)
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'formal_parameters' then append(get_text(child), ' ')
    elseif vim.startswith(type, 'function') then
      append('function')
      if node:type() == 'function_declaration' then append(' ') end
    elseif type == 'statement_block' then
      local replaced = get_text(child):gsub('\n%s*', ' '):gsub('%s*\n', ' ')
      append(replaced)
    else append(get_text(child))
    end
  end
  Node.replace(node, get())
  Node.goto_node(node)
end

function ECMAScript.join_arrow_function(node, options)
  local append, get = String.append('')
  for child in node:iter_children() do
    local type = child:type()
    if type == 'formal_parameters' or type == 'identifier' then append(get_text(child), ' ')
    elseif type == '=>' then
      append('=>', ' ')
      local next = child:next_sibling()
      if next:type() == 'statement_block' then
        local ainiklech = {}
        for gc in next:iter_children() do
          local gctype = gc:type()
          if gctype ~= '{' and gctype ~= '}' then
            table.insert(ainiklech, gc)
          end
        end
        if #ainiklech == 1 and ainiklech[1]:type() == 'return_statement' then
          local replaced = vim.trim(get_text(ainiklech[1]):gsub('return (.*);$', '%1'))
          append(replaced)
        else
          local replaced = get_text(next):gsub('%s*\n%s*', ' ')
          append(replaced)
        end
      end
    end
  end
  Node.replace(node, get():gsub('%s+$', ''))
  Node.goto_node(node)
end

-- function ECMAScript.split_comment(node, options)
--   local text = Node.get_text(node)
--   if String.is_multiline(text) or vim.startwith(text, '//') then return end
--   local indent = options.default_indent or ' '
--   local append, get = String.append('')
--   append(
--     '/**\n',
--     indent,
--     '* ',
--     text.gsub([[(^/**)|(*/$)]], '')
--     '\n */'
--   )
--   Node.replace(node, get())
--   Node.trim_line_end(node)
--   Node.trim_line_end(node, 1)
--   Node.goto_node(node)
-- end
--
-- function ECMAScript.join_comment(node, options)
--   local text = Node.get_text(node)
--   if String.is_multiline(text) or vim.startwith(text, '//') then return end
--   local row, col = node:range()
--   local comment = vim.treesitter.get_node{ pos = { row, col - 1 } }
--   local description = text.gsub([[(^/**)|(*/$)]], '');
--   Node.replace(comment, '/** ' .. description .. ' */')
--   Node.goto_node(comment)
-- end

return ECMAScript
