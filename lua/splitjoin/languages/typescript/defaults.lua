local Node = require'splitjoin.util.node'
local Buffer = require'splitjoin.util.buffer'

local get_node_text = vim.treesitter.get_node_text

---@type SplitjoinLanguageConfig
return {
  extends = 'ecmascript',

  -- config
  nodes = {

    union_type = {
      separator = '|',
      split = function(node, options)
        local n = node while Node.is_child_of('union_type', n) do n = n:parent() end
        local source = get_node_text(n, 0)
        local base_indent = Node.get_base_indent(n) or ''
        local indent = base_indent -- .. (U.get_config_indent('typescript', 'union_type') or '  ')
        local sep = options.sep_first and ('\n' .. indent .. '| ') or (' |\n'..indent)
        local prefix = options.sep_first and '\n'..indent..indent..'| ' or indent
        local replacement = prefix..source:gsub('|', sep)
        Node.replace(n, replacement)
        Node.trim_line_end(node)
        Node.goto_node(node)
        vim.cmd.norm'h'
      end,
      join = function(node, options)
        local n = node while Node.is_child_of('union_type', n) do n = n:parent() end
        local source = get_node_text(n, 0)
        local row = n:range()
        Node.replace(n, source:gsub('%s*', ''):gsub('^|', ''))
        if options.sep_first then
          Buffer.join_row_below(row - 1)
        end
      end,
    },

    type_arguments = {
      surround = {'<', '>'},
      trailing_separator = false,
    },

    type_parameters = {
      surround = {'<', '>'},
    },

  },

}
