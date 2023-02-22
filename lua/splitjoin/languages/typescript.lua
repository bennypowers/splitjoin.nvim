local U = require'splitjoin.util'

local flatten = vim.tbl_flatten
local map = vim.tbl_map

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
  operative_node = {
    union_type = function(node)
      local n = node
      local p = n:parent()
      while p and p:type() == 'union_type' do
        n = p
        p = n:parent()
      end
      return n
    end,
  },
  before = {
    union_type = function(op, _, _, lines)
      if op == 'split' then
        local sep_first = U.node_is_sep_first('typescript', 'union_type')
        if sep_first then
          table.insert(lines, 1, '')
        end
        return lines
      end
    end
  },
  after = {
    union_type = U.trim_end
  },
}
