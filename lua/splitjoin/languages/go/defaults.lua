local Node = require'splitjoin.util.node'
-- local DefaultHandlers = require'splitjoin.util.handlers'

---@type SplitjoinLanguageConfig
return {
  default_indent = '  ',
  trailing_separator = true,
  nodes = {
    -- Go struct fields
    field_declaration_list = {
      surround = { '{', '}' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    -- Go function parameters
    parameter_list = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    -- Go function returns (can be a parenthesized result group)
    result = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    -- Go function call arguments
    argument_list = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },
  }
}
