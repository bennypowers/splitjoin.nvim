local Node = require'splitjoin.util.node'
local Buffer = require'splitjoin.util.buffer'

local get_node_text = vim.treesitter.get_node_text


local function get_enclosing_union_node()
  local node = vim.treesitter.get_node()
  while node and node:type() ~= "union_type" do
    node = node:parent()
  end
  return node
end

local function find_matching_descendant(fn_node, ctx)
  local stack = {fn_node}
  while #stack > 0 do
    local node = table.remove(stack)
    local node_type = node:type()
    local node_text = Node.get_text(node)
    if node_type == ctx.type and node_text == ctx.text then
      return node
    end
    for child in node:iter_children() do
      table.insert(stack, child)
    end
  end
  return nil
end

local function set_cursor_to_node(node)
  if not node then return end
  local row, col = node:start()
  vim.api.nvim_win_set_cursor(0, {row + 1, col})
end

local function save_cursor_node_context()
  local node = vim.treesitter.get_node()
  if not node then return nil end
  local node_type = node:type()
  local node_text = vim.treesitter.get_node_text(node, 0)
  -- Traverse up to find the topmost union_type node (in case of nesting)
  local parent_union = node
  while parent_union and parent_union:type() ~= "union_type" do
    parent_union = parent_union:parent()
  end
  local union_start_row, union_start_col = parent_union and parent_union:start() or node:start()
  local node_start_row, node_start_col = node:start()
  local rel_row = node_start_row - union_start_row
  local rel_col = node_start_col
  return {
    type = node_type,
    text = node_text,
    rel_row = rel_row,
    rel_col = rel_col,
  }
end

---@type SplitjoinLanguageConfig
return {
  extends = 'ecmascript',

  -- config
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

        -- Force a reparse to update the tree
        vim.treesitter.get_parser(0):parse()

        -- After splitting, the original node `n` is gone.
        -- The new content is at the position of the old node.
        -- We need to find the new `union_type` node.
        -- The most reliable way is to get the node at the start position of the old node.
        local new_node_at_pos = vim.treesitter.get_node({ pos = { start_row, start_col } })

        -- This node might be a parent (e.g., type_alias_declaration).
        -- We need to find the `union_type` within it.
        local function find_union(parent)
            if not parent then return nil end
            if parent:type() == 'union_type' then return parent end
            for child in parent:iter_children() do
                local found = find_union(child)
                if found then return found end
            end
            return nil
        end

        local union_node = find_union(new_node_at_pos)

        if union_node then
            -- Place cursor at the beginning of the found union node
            local r, c = union_node:start()
            vim.api.nvim_win_set_cursor(0, {r + 1, c})
        else
            -- Fallback: move to where we started
            vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
        end
      end,
      join = function(node, options)
        local cursor_node_ctx = save_cursor_node_context() -- as before

        -- Ascend to the type_alias_declaration node
        local n = node
        while n and n:type() ~= 'type_alias_declaration' do
          n = n:parent()
        end
        if not n then return end

        -- Get and flatten the text
        local source = Node.get_text(n)
        -- Replace multiline with a flat union (strip newlines/indent, collapse "|")
        local collapsed = source
          :gsub("\n%s*|%s*", "|")
          :gsub("[\n\r]", " ")
          :gsub("%s*=%s*", " = ")
          :gsub("%s*;%s*$", ";")
          :gsub("= *|%s*", "= ")
          :gsub("^%s*|%s*", "")

        Node.replace(n, collapsed)

        -- Reacquire node and set cursor using previous logic
        local new_node = vim.treesitter.get_node()
        while new_node and new_node:type() ~= "union_type" do
          new_node = new_node:parent()
        end
        local match = cursor_node_ctx and new_node and find_matching_descendant(new_node, cursor_node_ctx)
        if match then
          set_cursor_to_node(match)
        else
          set_cursor_to_node(new_node)
        end
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
