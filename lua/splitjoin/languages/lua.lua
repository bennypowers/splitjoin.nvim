local U = require'splitjoin.util'

---@type SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      table_constructor = true,
    },
  },
  no_trailing_comma = {
    parameters = true,
    arguments = true,
    variable_list = true,
  },
  surround = {
    parameters = { '(', ')' },
    arguments = { '(', ')' },
    table_constructor = { '{', '}' },
  },
  before = {
    variable_list = function(lines, node, op)
      local parent = node:parent()
      local gp = parent and parent:parent()
      if gp and gp:type() == 'variable_declaration' then
        table.insert(lines, 1, '')
        return lines
      else
        return vim.tbl_map(function(x)
          return x:gsub('^%s+', '')
        end, lines)
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
          vim.cmd.norm'kddkJl'
        else
          U.jump_to_node_end_at(op, node, bufnr, winnr, row, col)
        end
      end
    end
  }
}
