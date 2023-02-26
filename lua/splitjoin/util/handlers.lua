local String = require'splitjoin.util.string'
local Node = require'splitjoin.util.node'
local filter = vim.tbl_filter
local map = vim.tbl_map

local DefaultHandlers = {}

function DefaultHandlers.split(node, options)
  local source = Node.get_text(node)
  local open, close = unpack(options.surround or {})
  local indent = options.default_indent or '  '
  local sep = options.separator or ','

  local unsurrounded = source

  if options.surround then
    unsurrounded = source:sub(#open+1, -(#close+1))
  end

  local lines = String.split(unsurrounded, sep)

  for i, line in ipairs(lines) do
    if options.sep_first then
      lines[i] = indent .. sep .. ' ' .. vim.trim(line)
    else
      lines[i] = indent .. vim.trim(line) .. sep
    end
  end

  if options.trailing_separator == false then
    lines[#lines] = lines[#lines]:gsub(sep, '')
  end

  if options.surround then
    table.insert(lines, 1, open)
    table.insert(lines, close)
  end

  lines = filter(function(line)
    return not line:find('^%s*'..sep..'%s*$')
  end, lines)

  local replacement = table.concat(lines, '\n')

  Node.replace(node, replacement)
  Node.goto_node(node)
end

function DefaultHandlers.join(node, options)
  local source = Node.get_text(node)
  if not source:find'\n' then return end

  local open, close = unpack(options.surround or {})
  local sep = options.separator or ','

  local inner = source

  if options.surround then
    inner = source:sub(#open+1, -(#close+1))
  end

  local lines = filter(String.is_lengthy, map(function(x)
    return vim.trim(x:gsub(sep, ''))
  end, String.split(inner, '\n')))

  local joined = table.concat(lines, sep)

  local list

  if options.sep_first then
    list = joined:gsub('%s*%'..sep, sep)
  else
    list = joined:gsub(sep..'%s*', sep..' ')
  end

  local padding = options.padding or ''
  local replacement = (open or '') .. padding .. vim.trim(list) .. padding .. (close or '')

  Node.replace(node, replacement)
  Node.goto_node(node)
end

return DefaultHandlers
