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



---@param node TSNode
local function split_attrs(node, options)
  local open_tag = node:parent()
  if open_tag then
    local base_indent = Node.get_base_indent(open_tag)
    local indent = base_indent .. (options.default_indent or '    ')
    if options.aligned then
      indent = base_indent .. vim.split(Node.get_text(open_tag), '%s')[1]:gsub('.', ' ') .. ' '
    end

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

    Node.replace(open_tag, get())

    Node.goto_node(node, 'start', 1)
    vim.treesitter.get_parser(0, 'html'):invalidate(true)
    vim.treesitter.get_parser(0, 'html'):invalidate(true)
  end
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
