local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'

--- HTML Functions
local HTML = {}

local function get_element(node)
  local element = node:parent()
  while element and element:type() ~= 'element' do
    element = element:parent()
  end
  return element
end

local function split_attrs(node, options)
  local parent = node:parent()
  local indent = options.default_indent or '  '
  if options.aligned then
    indent = vim.split(Node.get_text(parent), '%s', {})[1]:gsub('.', ' ') .. ' '
  end
  for child in parent:iter_children() do
    local child_type = child:type()
    if child_type == 'attribute' then
      local first_attr_child = child:parent():child(2)
      local prefix = ''
      if first_attr_child ~= child then
        prefix = '\n'..indent
      end
      Node.replace(child, prefix..Node.get_text(child))
    end
  end
  for child in parent:iter_children() do
    pcall(Node.trim_line_end,child)
  end
  Node.goto_node(node, 'start', 1)
end

local function split_children(node, options)
  local element = get_element(node)
  local base_indent = Node.get_base_indent(element)
  local indent = base_indent .. (options.default_indent or '  ')
  for child in element:iter_children() do
    local type = child:type()
    local prefix = '\n'..indent
    if type ~= 'start_tag' and type ~= 'end_tag' then
      Node.replace(child, prefix..Node.get_text(child))
    elseif type == 'end_tag' then
      Node.replace(child, '\n'..base_indent..Node.get_text(child))
    end
  end
  Node.goto_node(node, 'start', -1)
end

local function join_attrs(parent, options)
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

local function join_children(node, options)
  local element = get_element(node)
  local append, get = String.append('')

  for child in element:iter_children() do
    local type = child:type()
    if type == 'start_tag' or type == 'end_tag' then
      append(vim.trim(Node.get_text(child)))
    else
      append(vim.trim(Node.get_text(child)))
    end
  end

  Node.replace(element, get())
  Node.refresh(element)
  for child in element:iter_children() do if child:id() == node:id() then node = child end end
  Node.goto_node(node, 'start', 1)
end

function HTML.split(node, options)
  local capture = options.capture:gsub('splitjoin%.html%.', '')
  if capture == 'attr' then
    split_attrs(node, options)
  elseif capture == 'text' or capture == 'tag.start' or capture == 'tag.end' then
    split_children(node, options)
    Node.goto_node(node)
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
