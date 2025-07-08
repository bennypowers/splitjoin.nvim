local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'

--- HTML Functions
local HTML = {}

---@param node TSNode
---@return TSNode
local function get_element(node)
  local element = node:parent()
  while element and element:type() ~= 'element' do
    element = element:parent()
  end
  return element
end

local function join_attrs(parent)
  local append, get = String.append('')

  append('<')

  for child in parent:iter_children() do
    local type = child:type()
    if type == 'tag_name' then
      append(Node.get_text(child))
    elseif type == 'attribute' then
      append(' ', vim.trim(Node.get_text(child)))
    end
  end

  append('>')

  Node.replace(parent, get())
end



---@param node TSNode
local function split_attrs(node, options)
  local open_tag = node:parent()
  if open_tag then
    -- 1. Store original node info
    local original_node_text = Node.get_text(node)
    local original_node_type = node:type()
    local open_tag_srow, open_tag_scol, _, _ = open_tag:range()

    -- 2. Calculate correct indentation
    local base_indent = Node.get_base_indent(open_tag)
    local indent
    if options.aligned then
      local first_attr_node
      for child in open_tag:iter_children() do
        if child:type() == 'attribute' then
          first_attr_node = child
          break
        end
      end

      if first_attr_node then
        local _, first_attr_scol = first_attr_node:start()
        local base_indent_len = #base_indent
        local relative_indent_col = first_attr_scol - base_indent_len
        indent = string.rep(' ', relative_indent_col)
      else
        indent = (options.default_indent or '    ')
      end
    else
      indent = (options.default_indent or '    ')
    end

    -- 3. Build the new string
    local append, get = String.append('')
    append('<')
    local first_attr = true

    for child in open_tag:iter_children() do
      local type = child:type()
      if type == 'tag_name' then
        append(Node.get_text(child))
      elseif type == 'attribute' then
        if first_attr then
          append(' ' .. Node.get_text(child))
          first_attr = false
        else
          append('\n' .. indent .. Node.get_text(child))
        end
      end
    end
    append('>')

    -- 4. Replace the node
    Node.replace(open_tag, get())

    -- 5. Re-parse and find the new node to move cursor to
    vim.treesitter.get_parser(0, 'html'):invalidate(true)
    local tree = vim.treesitter.get_parser(0, 'html'):parse()[1]
    if not tree then
      Node.goto_node(node) -- fallback
      return
    end
    local root = tree:root()

    local new_open_tag = root:descendant_for_range(open_tag_srow, open_tag_scol, open_tag_srow, open_tag_scol)

    if new_open_tag and new_open_tag:type() == 'element' then
        for child in new_open_tag:iter_children() do
            if child:type() == 'start_tag' then
                new_open_tag = child
                break
            end
        end
    end

    local new_node_to_goto
    if new_open_tag and new_open_tag:type() == 'start_tag' then
      for child in new_open_tag:iter_children() do
        if child:type() == original_node_type and Node.get_text(child) == original_node_text then
          new_node_to_goto = child
          break
        end
      end
    end

    -- 6. Move cursor
    Node.goto_node(new_node_to_goto or node)
  end
end


local function split_children(node, options)
  local element = get_element(node)
  local base_indent = Node.get_base_indent(element)
  local indent = base_indent .. (options.default_indent or '  ')

  local start_tag
  local end_tag
  local children = {}
  for child in element:iter_children() do
    local type = child:type()
    if type == 'start_tag' then
      start_tag = child
    elseif type == 'end_tag' then
      end_tag = child
    else
      table.insert(children, child)
    end
  end

  if not start_tag then return nil end

  local new_text = Node.get_text(start_tag)
  for _, child in ipairs(children) do
    new_text = new_text .. '\n' .. indent .. vim.trim(Node.get_text(child))
  end
  if end_tag then
    new_text = new_text .. '\n' .. base_indent .. Node.get_text(end_tag)
  end

  local original_node_text = vim.trim(Node.get_text(node))
  local original_node_type = node:type()
  local srow, scol = element:start()

  Node.replace(element, new_text)

  vim.treesitter.get_parser(0, 'html'):invalidate(true)
  local tree = vim.treesitter.get_parser(0, 'html'):parse()[1]
  if not tree then return node end
  local root = tree:root()

  local new_element = root:descendant_for_range(srow, scol, srow, scol)
  if not new_element then return node end

  while new_element and new_element:type() ~= 'element' do
    new_element = new_element:parent()
  end

  if new_element then
    for child in new_element:iter_children() do
      if child:type() == original_node_type and vim.trim(Node.get_text(child)) == original_node_text then
        return child
      end
    end
  end

  return node -- Return old node as fallback
end


local function join_children(node, options)
  local element = get_element(node)
  local text = Node.get_text(element)
  text = text:gsub('\n%s*', ''):gsub('> ', '>')
  Node.replace(element, text)
  Node.refresh(element)
  for child in element:iter_children() do if child:id() == node:id() then node = child end end
  Node.goto_node(node, 'start', 1)
end



function HTML.split(node, options)
  local capture = options.capture:gsub('splitjoin%.html%.', '')
  if capture == 'attr' then
    split_attrs(node, options)
  elseif capture == 'text' or capture == 'tag.start' or capture == 'tag.end' then
    local new_node = split_children(node, options)
    Node.goto_node(new_node)
  end
end

function HTML.join(node, options)
  local capture = options.capture:gsub('splitjoin%.html%.', '')
  local parent = node:parent()
  if capture == 'attr' then
    join_attrs(parent, options)
  elseif capture == 'text' or capture == 'tag.start' or capture == 'tag.end' then
    join_children(node, options)
  end
end

return HTML
