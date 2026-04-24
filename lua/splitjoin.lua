---@class SplitjoinLanguageOptions
---@field default_indent? string|fun():string # indent for split items; defaults to '  '
---@field surround? string[] # tuple of open/close delimiters
---@field separator? string # item separator; defaults to ','
---@field separator_is_node? boolean # whether separator is a tree node; defaults to true
---@field padding? string # padding inside delimiters when joining
---@field trailing_separator? boolean # keep trailing separator when splitting; defaults to true
---@field split? fun(node: TSNode, options: SplitjoinLanguageOptions) # custom split handler
---@field join? fun(node: TSNode, options: SplitjoinLanguageOptions) # custom join handler
---@field capture? string # treesitter capture name, set at runtime
---@field lang? string # treesitter language name, set at runtime

---@class SplitjoinLanguageConfig
---@field default_indent? string|fun():string
---@field extends? string # inherit from another language's config
---@field nodes table<string, SplitjoinLanguageOptions>

---@class SplitjoinOptions
---@field languages? table<string, SplitjoinLanguageConfig>

local Splitjoin = {}

local function get_operable_node_under_cursor(bufnr, winnr)
  local Options = require'splitjoin.util.options'
  local Node = require'splitjoin.util.node'
  local get_query = vim.treesitter.query and vim.treesitter.query.get or vim.treesitter.get_query
  local get_parser = vim.treesitter.get_parser
  local is_in_node_range = vim.treesitter.is_in_node_range

  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  local cursor_range = { row - 1, col, row - 1, col }
  local tsparser = get_parser(bufnr)
     if tsparser == nil then return end
        tsparser:parse()
  local langtree = tsparser:language_for_range(cursor_range);
  local tstree = langtree:tree_for_range(cursor_range, { ignore_injections = false }) or langtree:trees()[1]
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

local _last_op = nil

local function clamp_cursor(bufnr, row, col)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  row = math.max(1, math.min(row, line_count))
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''
  col = math.max(0, math.min(col, #line - 1))
  return { row, col }
end

local function do_splitjoin(op)
  local Node = require'splitjoin.util.node'
  local node, options = get_operable_node_under_cursor(0, 0)
  if not node then return end
  if op == 'toggle' then
    op = Node.get_text(node):find('\n') and 'join' or 'split'
  end
  local saved_cursor = vim.api.nvim_win_get_cursor(0)
  local handler = options and options[op] or Node[op]
  handler(node, options)
  local restored = clamp_cursor(0, saved_cursor[1], saved_cursor[2])
  pcall(vim.api.nvim_win_set_cursor, 0, restored)
end

--- Operatorfunc callback for dot-repeat support.
--- Changes within the operatorfunc are grouped into a single undo entry.
function Splitjoin._opfunc(_)
  if _last_op then do_splitjoin(_last_op) end
end

local function make_action(op)
  return function()
    _last_op = op
    vim.go.operatorfunc = "v:lua.require'splitjoin'._opfunc"
    vim.cmd('normal! g@l')
  end
end

Splitjoin.join = make_action'join'
Splitjoin.split = make_action'split'
Splitjoin.toggle = make_action'toggle'

function Splitjoin.setup(opts)
  require'splitjoin.util.options'.setup(opts)
end

return Splitjoin
