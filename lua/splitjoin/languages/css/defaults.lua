local Node = require'splitjoin.util.node'

---@return SplitjoinLanguageConfig
return
  {
  nodes = {

    block = {
      surround = { '{', '}' },
      separator = ';',
      separator_is_node = false,
      join = Node.join,
      split = Node.split,
    },

    arguments = {
      surround = { '(', ')' },
      separator = ',',
      trailing_separator = false,
      join = Node.join,
      split = Node.split,
    },

  },
}
