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
    union_type = function(lines, node, op)
      if op == 'split' and U.is_sep_first('typescript', node:type()) then
        table.insert(lines, 1, '')
      end
      return lines
    end
  },
  after = {
    union_type = U.trim_end,
  },
}
