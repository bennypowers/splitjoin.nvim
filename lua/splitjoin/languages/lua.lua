local U = require'splitjoin.util'

---@type SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      table_constructor = true,
    },
  },

  handlers = {
    if_statement = {
      split = function(node)
        local indent = U.get_config_indent('lua', 'if_statement') or '  '
        U.node_replace(node, vim.treesitter.get_node_text(node, 0)
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
        U.node_cursor_to_end(node)
      end,
      join = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        U.node_replace(node, source
                               :gsub('if%s+', 'if ')
                               :gsub('%s*then%s+', ' then ')
                               :gsub('%s*elseif%s+', ' elseif ')
                               :gsub('%s*else%s+', ' else ')
                               :gsub('%s*end%s*', ' end'))
      end
    },

    variable_list = {
      split = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        local is_variable_decl = U.node_is_child_of('variable_declaration', node)
        local indent = is_variable_decl and '      ' or ''
        local new = source:gsub(',%s*',',\n'..indent)
        U.node_replace(node, new)
        U.node_cursor_to_end(node)
        if is_variable_decl then U.node_trim_line_end(node) end
      end,
      join = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        local next = source:gsub('%s+', ' ')
        U.node_replace(node, next)
        U.node_cursor_to_end(node)
      end
    }
  },

  no_trailing_comma = {
    parameters = true,
    arguments = true,
    variable_list = true,
    if_statement = true,
  },

  surround = {
    parameters = { '(', ')' },
    arguments = { '(', ')' },
    table_constructor = { '{', '}' },
  },

}
