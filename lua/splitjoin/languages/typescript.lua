local U = require'splitjoin.util'

---@type SplitjoinLanguageConfig
return {
  extends = 'ecmascript',
  options = {
    sep_first = {
      union_type = true,
    },
  },
  separators = {
    union_type = '|',
  },
  before = {
    union_type = function(op, node, base_indent, lines)
      if op == 'split' and U.node_is_sep_first('typescript', node:type()) then
        table.insert(lines, 1, '')
      end
      return lines
    end
  },
  after = {
    union_type = U.trim_end,
  },
}
