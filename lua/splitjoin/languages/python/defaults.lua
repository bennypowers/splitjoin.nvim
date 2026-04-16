local String = require'splitjoin.util.string'

---@type SplitjoinLanguageConfig
return {

  default_indent = String.buffer_indent,

  nodes = {
    parameters    = { surround = { '(', ')' } },
    argument_list = { surround = { '(', ')' } },
    list          = { surround = { '[', ']' } },
    dictionary    = { surround = { '{', '}' } },
    tuple         = { surround = { '(', ')' } },
    set           = { surround = { '{', '}' } },
  },

}
