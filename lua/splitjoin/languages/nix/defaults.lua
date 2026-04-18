local Nix = require'splitjoin.languages.nix.functions'

---@type SplitjoinLanguageConfig
return {

  nodes = {
    list_expression = {
      split = Nix.split_list,
      join = Nix.join_list,
    },
  },

}
