-- STRING HELPERS
local String = {}

function String.is_lengthy(str)
  return #str > 0
end

function String.split(str, sep, opts)
  opts = vim.tbl_extend('keep', opts or {}, { plain = true, trimempty = true })
  return vim.split(str, sep, opts)
end

return String
