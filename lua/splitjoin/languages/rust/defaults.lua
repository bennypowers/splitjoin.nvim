---@type SplitjoinLanguageConfig
return {

  nodes = {
    parameters          = { surround = { '(', ')' } },
    arguments           = { surround = { '(', ')' } },
    tuple_expression    = { surround = { '(', ')' } },
    field_declaration_list = { surround = { '{', '}' }, padding = ' ' },
    enum_variant_list   = { surround = { '{', '}' }, padding = ' ' },
    use_list            = { surround = { '{', '}' } },
    token_tree          = { surround = { '[', ']' } },
    match_block         = { surround = { '{', '}' } },
  },

}
