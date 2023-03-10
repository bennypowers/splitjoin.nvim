local Node = require'splitjoin.util.node'

---@type SplitjoinLanguageConfig
return {

  nodes = {

    object = {
      surround = { '{', '}' },
      split = Node.split,
      join = Node.join,
      trailing_separator = false,
    },

    array = {
      surround = { '[', ']' },
      split = Node.split,
      join = Node.join,
      trailing_separator = false,
    },

  },

}
