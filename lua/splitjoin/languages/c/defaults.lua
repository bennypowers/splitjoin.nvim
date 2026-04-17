---@type SplitjoinLanguageConfig
return {

  nodes = {
    parameter_list   = { surround = { '(', ')' }, trailing_separator = false },
    argument_list    = { surround = { '(', ')' }, trailing_separator = false },
    initializer_list = { surround = { '{', '}' } },
    enumerator_list  = { surround = { '{', '}' }, padding = ' ' },
    field_declaration_list = {
      surround = { '{', '}' },
      separator = ';',
      separator_is_node = false,
    },
  },

}
