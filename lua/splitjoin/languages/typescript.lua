local U = require'splitjoin.util'

---@type SplitjoinLanguageConfig
return {
  extends = 'ecmascript',
  options = {
    sep_first = {
      union_type = true,
    },
  },

  -- config
  separators = {
    union_type = '|',
  },

  surround = {
    type_parameters = {'<', '>'},
    type_arguments = {'<', '>'},
  },

  no_trailing_comma = {
    type_arguments = true,
  },

  -- hooks
  handlers = {
    union_type = {
      split = function(node)
        local n = node while U.node_is_child_of('union_type', n) do n = n:parent() end
        local sep_first = U.node_is_sep_first('typescript', 'union_type')
        local source = vim.treesitter.get_node_text(n, 0)
        local base_indent = U.node_get_base_indent(n) or ''
        local indent = base_indent -- .. (U.get_config_indent('typescript', 'union_type') or '  ')
        local sep = sep_first and ('\n' .. indent .. '| ') or (' |\n'..indent)
        local prefix = sep_first and '\n'..indent..indent..'| ' or indent
        local replacement = prefix..source:gsub('|', sep)
        U.node_replace(n, replacement)
        U.node_trim_line_end(node)
        U.node_cursor_to_end(node)
        vim.cmd.norm'h'
      end,
      join = function(node)
        local n = node while U.node_is_child_of('union_type', n) do n = n:parent() end
        local source = vim.treesitter.get_node_text(n, 0)
        local row = n:range()
        U.node_replace(n, source:gsub('%s*', ''):gsub('^|', ''))
        local sep_first = U.node_is_sep_first('typescript', 'union_type')
        if sep_first then
          U.buffer_join_row_below(row - 1)
        end
      end,
    }
  },

}
