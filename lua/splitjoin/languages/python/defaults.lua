local Node = require'splitjoin.util.node'
local String = require'splitjoin.util.string'

---@type SplitjoinLanguageConfig
return {

  default_indent = String.buffer_indent,

  nodes = {

    parameters = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    argument_list = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    list = {
      surround = { '[', ']' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    dictionary = {
      surround = { '{', '}' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    tuple = {
      surround = { '(', ')' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    set = {
      surround = { '{', '}' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

  },

}
