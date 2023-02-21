---@return SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      block = true,
    },
  },
  surround = {
    block = { '{', '}' },
  },
  separators = {
    block = ';',
  },
  before = {
    block = function(op, _, _, lines)
      if op == 'join' then
        -- lines[#lines] = lines[#lines] .. ';'
      end
    end
  }
}
