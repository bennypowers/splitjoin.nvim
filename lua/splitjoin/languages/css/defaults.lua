local CSS = require'splitjoin.languages.css.functions'

---@return SplitjoinLanguageConfig
return
  {
  nodes = {

    block = {
      surround = { '{', '}' },
      separator = ';',
      separator_is_node = false,
    },

    arguments = {
      surround = { '(', ')' },
      trailing_separator = false,
    },

    declaration = {
      split = CSS.split_declaration,
      join = CSS.join_declaration,
    },

  },
}
