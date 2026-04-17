---@type SplitjoinLanguageConfig
return {
  extends = 'c',

  nodes = {
    template_argument_list  = { surround = { '<', '>' }, trailing_separator = false },
    template_parameter_list = { surround = { '<', '>' }, trailing_separator = false },
  },

}
