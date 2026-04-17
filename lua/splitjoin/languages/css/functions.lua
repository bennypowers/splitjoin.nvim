local Node = require'splitjoin.util.node'

local CSS = {}

local skip_types = { property_name = true, [':'] = true, [';'] = true }

function CSS.split_declaration(node, options)
  local indent = options.default_indent or '  '
  local values = {}
  local past_colon = false

  for child in node:iter_children() do
    local type = child:type()
    if type == ':' then
      past_colon = true
    elseif past_colon and not skip_types[type] then
      if type == ',' then
        local prev = values[#values]
        if prev then prev.comma = true end
      else
        table.insert(values, { text = vim.trim(Node.get_text(child)) })
      end
    end
  end

  if #values < 2 then return end

  local prop = Node.get_text(node:child(0))
  local lines = { prop .. ':\n' }
  for i, v in ipairs(values) do
    local suffix = v.comma and ',' or (i == #values and ';' or '')
    table.insert(lines, indent .. v.text .. suffix .. '\n')
  end

  -- remove trailing \n from last line
  lines[#lines] = lines[#lines]:gsub('\n$', '')

  Node.replace(node, table.concat(lines, ''))
  Node.goto_node(node)
end

function CSS.join_declaration(node, options)
  local text = Node.get_text(node)
  if not text:find('\n') then return end

  local values = {}
  local past_colon = false

  for child in node:iter_children() do
    local type = child:type()
    if type == ':' then
      past_colon = true
    elseif past_colon and not skip_types[type] then
      if type == ',' then
        local prev = values[#values]
        if prev then prev.comma = true end
      else
        table.insert(values, { text = vim.trim(Node.get_text(child)) })
      end
    end
  end

  local prop = Node.get_text(node:child(0))
  local parts = {}
  for _, v in ipairs(values) do
    table.insert(parts, v.text .. (v.comma and ',' or ''))
  end

  local joined = prop .. ': ' .. table.concat(parts, ' ') .. ';'
  Node.replace(node, joined)
  Node.goto_node(node)
end

return CSS
