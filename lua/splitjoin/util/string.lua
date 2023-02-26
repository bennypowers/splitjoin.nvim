local filter = vim.tbl_filter

-- STRING HELPERS
local String = {}

function String.is_lengthy(str)
  return #str > 0
end

function String.split(str, sep, opts)
  opts = vim.tbl_extend('keep', opts or {}, { plain = true, trimempty = true })
  return vim.split(str, sep, opts)
end

function String.filter_only_whitespace(lines)
  return filter(function(line) return String.is_lengthy(vim.trim(line)) end, lines)
end

function String.append(target)
  local replacement = target
  local function get() return replacement end
  local function append(...)
    for _, str in ipairs{ ... } do
      replacement = replacement .. str
    end
  end
  return append, get
end

return String
