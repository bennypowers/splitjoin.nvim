local Node = require'splitjoin.util.node'

---@type SplitjoinLanguageConfig
return {

  nodes = {

    object = {
      surround = { '{', '}' },
      split = Node.split,
      join = Node.join,
    },

    array = {
      surround = { '[', ']' },
      split = Node.split,
      join = Node.join,
    },

    arguments = {
      surround = { '(', ')' },
      split = Node.split,
      join = Node.join,
    },

    formal_parameters = {
      surround = { '(', ')' },
      split = Node.split,
      join = Node.join,
    },

    named_imports = {
      surround = { '{', '}' },
    },

  },

}
