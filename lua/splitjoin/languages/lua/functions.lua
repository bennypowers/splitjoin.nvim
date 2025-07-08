local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'
local ts_utils = require"nvim-treesitter.ts_utils"
local get_text = Node.get_text

local Lua = {}

local function save_cursor_node_context()
  local node = ts_utils.get_node_at_cursor()
  if not node then return nil end
  local node_type = node:type()
  local node_text = get_text(node)
  -- Optionally, get relative offset from function node start
  local parent_fn = node
  while parent_fn and not vim.tbl_contains({"function_declaration", "function_definition"}, parent_fn:type()) do
    parent_fn = parent_fn:parent()
  end
  local fn_start_row, fn_start_col = parent_fn:start()
  local node_start_row, node_start_col = node:start()
  local rel_row = node_start_row - fn_start_row
  local rel_col = node_start_col
  return {
    type = node_type,
    text = node_text,
    rel_row = rel_row,
    rel_col = rel_col,
  }
end

local function get_enclosing_function_node()
  local node = ts_utils.get_node_at_cursor()
  while node and not vim.tbl_contains({"function_declaration", "function_definition"}, node:type()) do
    node = node:parent()
  end
  return node
end

local function find_matching_descendant(fn_node, ctx)
  -- Recursively traverse all descendants of fn_node
  local stack = {fn_node}
  while #stack > 0 do
    local node = table.remove(stack)
    -- Get node type and text
    local node_type = node:type()
    local node_text = get_text(node)
    -- Check for match
    if node_type == ctx.type and node_text == ctx.text then
      return node
    end
    -- Add children to stack
    for child in node:iter_children() do
      table.insert(stack, child)
    end
  end
  return nil
end

local function set_cursor_to_node(node)
  if not node then return end
  local row, col = node:start()
  vim.api.nvim_win_set_cursor(0, {row + 1, col})
end

function Lua.split_function(node, options)
  local cursor_node_ctx = save_cursor_node_context()
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
  local new_fn_node = get_enclosing_function_node()
  if cursor_node_ctx and new_fn_node then
    local match = find_matching_descendant(new_fn_node, cursor_node_ctx)
    if match then
      set_cursor_to_node(match)
    else
      -- fallback: put cursor at start of function
      set_cursor_to_node(new_fn_node)
    end
  end
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
