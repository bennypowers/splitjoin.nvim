-- BUFFER ROW HELPERS
local Buffer = {}

function Buffer.get_line(bufnr, row)
  local line = unpack(vim.api.nvim_buf_get_lines(bufnr,
                                                 row,
                                                 row + 1,
                                                 true))
  return line
end

function Buffer.join_row_below(row)
  local fst = Buffer.get_line(0, row)
  local snd = Buffer.get_line(0, row + 1)
  vim.api.nvim_buf_set_lines(0,
                             row,
                             row + 2,
                             true,
                             { fst:gsub('%s*$',' ') .. snd:gsub('^%s*', '') })
end

return Buffer
