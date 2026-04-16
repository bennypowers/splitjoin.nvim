local filter = vim.tbl_filter

-- STRING HELPERS
local String = {}

function String.is_lengthy(str)
  return #str > 0
end

function String.is_multiline(str)
  return #vim.split(vim.fn.trim(str), '\n') > 1
end

function String.is_singleline(str)
  return #vim.split(vim.fn.trim(str), '\n') == 1
end

function String.split(str, sep, opts)
  opts = vim.tbl_extend('keep', opts or {}, { plain = true, trimempty = true })
  return vim.split(str, sep, opts)
end

function String.filter_only_whitespace(lines)
  return filter(function(line) return String.is_lengthy(vim.trim(line)) end, lines)
end

--- Derive indent string from current buffer settings.
--- Use as fallback for languages with semantic whitespace (e.g. Python)
--- where a hardcoded default_indent would be wrong.
function String.buffer_indent()
  local sw = vim.bo.shiftwidth
  local width = sw > 0 and sw or vim.bo.tabstop
  local char = vim.bo.expandtab == false and '\t' or ' '
  return string.rep(char, char == '\t' and 1 or width)
end

function String.append(target)
  local replacement = target
  local function get()
    local r = replacement
    replacement = nil
    return r
  end
  local function append(...)
    for _, str in ipairs{ ... } do
      replacement = replacement .. str
    end
  end
  return append, get
end

return String
