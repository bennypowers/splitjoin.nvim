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
        local source = vim.treesitter.get_node_text(node, 0)
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
