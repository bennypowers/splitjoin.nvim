local Options = require'splitjoin.util.options'
local DefaultHandlers = require'splitjoin.util.handlers'

local Splitjoin = {}

local function get_operable_node_and_lang_under_cursor (bufnr, winnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  -- TODO: cache a reference per bufnr
  local tsparser = vim.treesitter.get_parser(bufnr)
  local tstree = tsparser:parse()[1]
  local langtree = tsparser:language_for_range { row, col, row, col };
  local lang = langtree:lang()
  local query = vim.treesitter.get_query(lang, 'splitjoin')
  local nodes = {}
  if query then
    for _, node, _ in query:iter_captures(tstree:root(), bufnr, row - 1, row) do
      if vim.treesitter.is_in_node_range(node, row - 1, col) then
        table.insert(nodes, node)
      end
    end
  end

  local node = nodes[#nodes]
  if node then
    return node, lang
  end
end

local function splitjoin(op)
  return function()
    local bufnr = 0
    local winnr = 0
    local node, lang = get_operable_node_and_lang_under_cursor(bufnr, winnr)
    if node then
      local options = Options.get_options_for(lang, node:type())
      local handler = options[op] or DefaultHandlers[op]
      handler(node, options)
    end
  end
end

Splitjoin.join = splitjoin('join')
Splitjoin.split = splitjoin('split')
Splitjoin.setup = Options.setup

return Splitjoin;
