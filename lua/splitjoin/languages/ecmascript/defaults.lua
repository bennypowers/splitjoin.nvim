local Node = require'splitjoin.util.node'
local ECMAScript = require'splitjoin.languages.ecmascript.functions'

---@type SplitjoinLanguageConfig
return {

  nodes = {

    object = {
      surround = { '{', '}' },
      split = Node.split,
      join = Node.join,
    },

    object_pattern = {
      surround = { '{', '}' },
      padding = ' ',
      split = Node.split,
      join = Node.join,
    },

    array = {
      surround = { '[', ']' },
      split = Node.split,
      join = Node.join,
    },

    array_pattern = {
      surround = { '[', ']' },
      split = Node.split,
      join = Node.join,
    },

    named_imports = {
      surround = { '{', '}' },
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

    function_declaration = {
      split = ECMAScript.split_function,
      join = ECMAScript.join_function,
    },

    function_expression = {
      split = ECMAScript.split_function,
      join = ECMAScript.join_function,
    },

    arrow_function = {
      split = ECMAScript.split_arrow_function,
      join = ECMAScript.join_arrow_function,
    },

  },

}
