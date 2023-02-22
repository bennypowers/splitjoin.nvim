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
        U.replace_node(node, vim.treesitter.get_node_text(node, 0)
                               :gsub('%s+then%s+',   ' then\n'..indent)
                               :gsub('%s+else%s+',   '\nelse\n'..indent)
                               :gsub('%s+end%s*',    '\nend')
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
        U.cursor_to_node_end(node)
      end,
      join = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        U.replace_node(node, source
                               :gsub('if%s+', 'if ')
                               :gsub('%s*then%s+', ' then ')
                               :gsub('%s*elseif%s+', ' elseif ')
                               :gsub('%s*else%s+', ' else ')
                               :gsub('%s*end%s*', ' end'))
      end
    },
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

  before = {
    variable_list = function(op, node, base_indent, lines)
      if op == 'split' then
        local parent = node:parent()
        local gp = parent and parent:parent()
        if gp and gp:type() == 'variable_declaration' then
          table.insert(lines, 1, '')
          return lines
        else
          local next = vim.tbl_map(function(x)
            return x:gsub('^%s*', base_indent or '')
          end, lines)
          next[1] = next[1]:gsub('^%s+', '')
          return next
        end
      else
        return lines
      end
    end
  },

  after = {
    variable_list = function(op, node, bufnr, winnr, row, col)
      local parent = node:parent()
      local gp = parent and parent:parent()
      if op == 'split' then
        if gp and gp:type() == 'variable_declaration' then
          U.trim_end(op, node, bufnr, winnr, row, col)
        else
          U.jump_to_node_end_at(op, node, bufnr, winnr, row, col)
        end
      else -- 'join'
        if gp and gp:type() == 'variable_declaration' then
          -- vim.cmd.norm'k"_dd'
          vim.cmd.norm'kJl'
        else
          U.jump_to_node_end_at(op, node, bufnr, winnr, row, col)
        end
      end
    end
  }
}
