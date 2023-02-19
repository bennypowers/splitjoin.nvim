---@type SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      table_constructor = true,
    },
  },
  no_trailing_comma = {
    parameters = true,
    arguments = true,
    variable_list = true,
  },
  surround = {
    parameters = true,
    arguments = true,
    table_constructor = true,
  },
}
