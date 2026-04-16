local ECMAScript = require'splitjoin.languages.ecmascript.functions'

---@type SplitjoinLanguageConfig
return {

  nodes = {

    object = {
      surround = { '{', '}' },
    },

    object_pattern = {
      surround = { '{', '}' },
      padding = ' ',
    },

    array = {
      surround = { '[', ']' },
    },

    array_pattern = {
      surround = { '[', ']' },
    },

    named_imports = {
      surround = { '{', '}' },
    },

    arguments = {
      surround = { '(', ')' },
    },

    formal_parameters = {
      surround = { '(', ')' },
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

    comment = {
      default_indent = ' ',
      split = ECMAScript.split_comment,
      join = ECMAScript.join_comment,
    }

  },

}
