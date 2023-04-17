local Options = require'splitjoin.util.options'
local Node = require'splitjoin.util.node'
local DefaultHandlers = require'splitjoin.util.handlers'
local get_query = vim.treesitter.query and vim.treesitter.query.get or vim.treesitter.get_query
local get_parser = vim.treesitter.get_parser
local is_in_node_range = vim.treesitter.is_in_node_range

---@class SplitjoinLanguageOptions
---@field default_indent string
---@field surround string[] tuple of surround strings
---@field separator string=','
---@field padding string
---@field trailing_separator boolean=true

---@class SplitjoinOptions
---@field default_indent string
---@field languages table<string, SplitjoinLanguageOptions>

local Splitjoin = {}

local function get_operable_node_under_cursor(bufnr, winnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  local cursor_range = { row, col, row, col }
  -- TODO: cache a reference per bufnr
  local tsparser = get_parser(bufnr)
        tsparser:parse()
  local langtree = tsparser:language_for_range(cursor_range);
  local tstree = langtree:tree_for_range(cursor_range, { ignore_injections = false })
  if not tstree then return nil, nil end
  local lang = langtree:lang()
  local query = get_query(lang, 'splitjoin')
  local nodes = {}

  if query then
    for id, node, _ in query:iter_captures(tstree:root(), bufnr, row - 1, row) do
      if is_in_node_range(node, row - 1, col) then
        table.insert(nodes, { node, query.captures[id] })
      end
    end
  end

  local result = nodes[#nodes]

  if result then
    local node, name = unpack(result)
    local options = Options.get_options_for(lang, node:type()) or {}
          options.capture = name
          options.lang = lang
    Node.cache_parser(node, tsparser)
    return node, options
  end
end

local function splitjoin(op)
  return function()
    local bufnr = 0
    local winnr = 0
    local node, options = get_operable_node_under_cursor(bufnr, winnr)
    if node then
      local handler = options and options[op] or DefaultHandlers[op]
      handler(node, options)
    end
  end
end

Splitjoin.join = splitjoin'join'
Splitjoin.split = splitjoin'split'
Splitjoin.setup = function(opts) Options.setup(opts) end

return Splitjoin
