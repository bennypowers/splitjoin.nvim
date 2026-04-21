local Yaml = require'splitjoin.languages.yaml.functions'

---@type SplitjoinLanguageConfig
return {

  nodes = {
    flow_sequence = { surround = { '[', ']' }, split = Yaml.split_flow_sequence },
    flow_mapping  = { surround = { '{', '}' } },
    block_sequence = { split = function() end, join = Yaml.join_block_sequence },
  },

}
