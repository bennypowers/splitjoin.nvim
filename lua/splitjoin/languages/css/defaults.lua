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

  },
}
