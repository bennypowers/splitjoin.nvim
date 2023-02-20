---@type SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      object = true,
    },
  },
  surround = {
    object = { '{', '}' },
    array = { '[', ']' },
    arguments = { '(', ')' },
    formal_parameters = { '(', ')' },
  },
}
