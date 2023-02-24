local Node = require'splitjoin.util.node'

---@type SplitjoinLanguageConfig
return {

  nodes = {

    arguments = {
      trailing_separator = false,
      surround = { '(', ')' },
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
      trailing_separator = false,
      surround = { '(', ')' },
    },

    table_constructor = {
      surround = { '{', '}' },
      separator = ',',
      split = function(node, options)
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
            table.insert(lines, indent..vim.trim(Node.get_text(child)) .. sep)
          end
        end
        Node.replace(node, table.concat(lines, ''))
        Node.cursor_to_end(node)
      end,
      join = function(node, options)
        local replacement = ''
        local sep = options.separator or ','
        local open, close = unpack(options.surround or {})
        local function c(s, t) replacement = replacement .. s .. (t or '') end
        local padding = options.padding or ''
        for child in node:iter_children() do
          local type = child:type()
          if     type == open then     c(type, padding)
          elseif type == sep then
            local last = Node.next_sibling_is(child, close)
            c(last and '' or type, last and '' or padding)
          elseif type == close then     c(padding, type)
          else
            c(vim.trim(Node.get_text(child)))
          end
        end
        Node.replace(node, replacement)
        Node.cursor_to_end(node)
      end
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
