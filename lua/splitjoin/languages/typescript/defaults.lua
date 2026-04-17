local Node = require'splitjoin.util.node'

local get_node_text = vim.treesitter.get_node_text

local function save_cursor_node_context()
  local node = vim.treesitter.get_node()
  if not node then return nil end
  local parent_union = node
  while parent_union and parent_union:type() ~= "union_type" do
    parent_union = parent_union:parent()
  end
  local union_start_row, _ = parent_union and parent_union:start() or node:start()
  local node_start_row, node_start_col = node:start()
  return {
    type = node:type(),
    text = vim.treesitter.get_node_text(node, 0),
    rel_row = node_start_row - union_start_row,
    rel_col = node_start_col,
  }
end

---@type SplitjoinLanguageConfig
return {
  extends = 'ecmascript',

  nodes = {

    union_type = {
      separator = '|',
      split = function(node, options)
        local n = node while Node.is_child_of('union_type', n) do n = n:parent() end
        local source = get_node_text(n, 0)
        local base_indent = Node.get_base_indent(n) or ''
        local indent = base_indent
        local sep = options.sep_first and ('\n' .. indent .. '| ') or (' |\n'..indent)
        local prefix = options.sep_first and '\n'..indent..indent..'| ' or indent
        local replacement = prefix..source:gsub('|', sep)

        local start_row, start_col = n:start()

        Node.replace(n, replacement)
        Node.trim_line_end(node)

        vim.treesitter.get_parser(0):parse()

        local new_node_at_pos = vim.treesitter.get_node({ pos = { start_row, start_col } })
        local union_node = new_node_at_pos and Node.find_descendant(new_node_at_pos, function(nd)
          return nd:type() == 'union_type'
        end)

        if union_node then
          Node.goto_node(union_node, 'start', 1)
        else
          vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
        end
      end,
      join = function(node, options)
        local cursor_ctx = save_cursor_node_context()

        local n = node
        while n and n:type() ~= 'type_alias_declaration' do
          n = n:parent()
        end
        if not n then return end

        local source = Node.get_text(n)
        local collapsed = source
          :gsub("\n%s*|%s*", "|")
          :gsub("[\n\r]", " ")
          :gsub("%s*=%s*", " = ")
          :gsub("%s*;%s*$", ";")
          :gsub("= *|%s*", "= ")
          :gsub("^%s*|%s*", "")

        Node.replace(n, collapsed)

        local new_node = vim.treesitter.get_node()
        while new_node and new_node:type() ~= "union_type" do
          new_node = new_node:parent()
        end
        local match = cursor_ctx and new_node and Node.find_descendant(new_node, function(nd)
          return nd:type() == cursor_ctx.type and Node.get_text(nd) == cursor_ctx.text
        end)
        Node.goto_node(match or new_node, 'start', 1)
      end
    },

    type_arguments = {
      surround = {'<', '>'},
      trailing_separator = false,
    },

    type_parameters = {
      surround = {'<', '>'},
    },

  },

}
