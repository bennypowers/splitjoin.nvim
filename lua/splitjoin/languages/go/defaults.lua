local Node = require'splitjoin.util.node'
local Go = require'splitjoin.languages.go.functions'

---@type SplitjoinLanguageConfig
return {
  default_indent = '  ',
  nodes = {
    -- Go struct fields
    field_declaration_list = {
      surround = { '{', '}' },
      split = Go.split_struct,
      join = Go.join_struct,
    },

    -- Go function parameters and return lists
    parameter_list = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
      trailing_separator = true,
    },

    -- Go function call arguments
    argument_list = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    -- Go slice, map, and composite literals
    literal_value = {
      surround = { '{', '}' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    }
  }
}
