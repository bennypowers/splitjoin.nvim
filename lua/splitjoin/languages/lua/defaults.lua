local Node = require'splitjoin.util.node'

local function luasplit (node, options)
  local indent = options.default_indent or '  '
  local sep = options.separator or ','
  local open, close = unpack(options.surround or {})
  local lines = {}
  for child in node:iter_children() do
    local type = child:type()
    if     type == open then     table.insert(lines, open..'\n')
    elseif type == sep then     table.insert(lines, '\n')
    elseif type == close then     table.insert(lines, '\n'..close)
    else
      local line = indent .. vim.trim(Node.get_text(child)) .. sep
      table.insert(lines, line)
    end
  end
  if options.trailing_separator == false then
    local index = #lines
    if close and #close > 0 then index = index - 1 end
    lines[index] = lines[index]:gsub(sep..'$', '')
  end
  Node.replace(node, table.concat(lines, ''))
  Node.cursor_to_end(node)
end

local function luajoin(node, options)
  local replacement = ''
  local sep = options.separator or ','
  local open, close = unpack(options.surround or {})
  local function c(s, t) replacement = replacement .. s .. (t or '') end
  local padding = options.padding or ''
  for child in node:iter_children() do
    local type = child:type()
    if     type == open then  c(type, padding)
    elseif type == close then c(padding, type)
    elseif type == sep then
      if Node.next_sibling_is(child, close) then
        c('', '')
      else
        c(sep, ' ') -- TODO: inner vs outer padding
      end
    else
      c(vim.trim(Node.get_text(child)))
    end
  end
  Node.replace(node, replacement)
  Node.cursor_to_end(node)
end

---@type SplitjoinLanguageConfig
return {

  nodes = {

    arguments = {
      surround = { '(', ')' },
      separator = ',',
      trailing_separator = false,
      split = Node.split,
      join = Node.join,
    },

    if_statement = {
      trailing_separator = false,
      split = function(node, options)
        local indent = options.indent or '  '
        Node.replace(node, vim.treesitter.get_node_text(node, 0)
                               :gsub('%s+then%s+',   ' then\n'..indent)
                               :gsub('%s+else%s+',   '\nelse\n'..indent)
                               :gsub('%s*end%s*',    '\nend')
                               :gsub(
                                 '%s+elseif%s+(.*)then%s+',
                                 function(s)
                                   return '\n'
                                    .. 'elseif '
                                    .. vim.trim(s)
                                    .. ' then'
                                    .. '\n'
                                    ..indent
                                 end
                               ))
        Node.cursor_to_end(node)
      end,
      join = function(node)
        local source = Node.get_text(node)
        Node.replace(node, source
                               :gsub('if%s+', 'if ')
                               :gsub('%s*then%s+', ' then ')
                               :gsub('%s*elseif%s+', ' elseif ')
                               :gsub('%s*else%s+', ' else ')
                               :gsub('%s*end%s*', ' end'))
      end
    },

    parameters = {
      surround = { '(', ')' },
      trailing_separator = false,
    },

    table_constructor = {
      surround = { '{', '}' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    variable_list = {
      trailing_separator = false,
      split = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        local is_variable_decl = Node.is_child_of('variable_declaration', node)
        local indent = is_variable_decl and '      ' or ''
        local new = source:gsub(',%s*',',\n'..indent)
        Node.replace(node, new)
        Node.cursor_to_end(node)
        if is_variable_decl then Node.trim_line_end(node) end
      end,
      join = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        local next = source:gsub('%s+', ' ')
        Node.replace(node, next)
        Node.cursor_to_end(node)
      end
    },

  },

}
