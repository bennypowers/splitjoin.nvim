---@type SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      object = true,
      named_imports = true,
    },
  },
  surround = {
    object = { '{', '}' },
    array = { '[', ']' },
    arguments = { '(', ')' },
    formal_parameters = { '(', ')' },
    named_imports = { '{', '}' },
  },
}
