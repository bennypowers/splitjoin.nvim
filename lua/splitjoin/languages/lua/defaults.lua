local Node = require'splitjoin.util.node'
local Lua = require'splitjoin.languages.lua.functions'

local get_node_text = vim.treesitter.get_node_text

---@type SplitjoinLanguageConfig
return {

  nodes = {

    arguments = {
      surround = { '(', ')' },
      separator = ',',
      trailing_separator = false,
      split = Node.split,
      join = Node.join,
    },

    function_declaration = {
      split = Lua.split_function,
      join = Lua.join_function,
    },

    function_definition = {
      split = Lua.split_function,
      join = Lua.join_function,
    },

    if_statement = {
      trailing_separator = false,
      surround = { 'if', 'end' },
      split = Lua.split_if,
      join = Lua.join_if,
    },

    parameters = {
      surround = { '(', ')' },
      trailing_separator = false,
    },

    table_constructor = {
      surround = { '{', '}' },
      separator = ',',
      split = Node.split,
      join = Node.join,
    },

    variable_list = {
      trailing_separator = false,
      split = function(node)
        local source = get_node_text(node, 0)
        local is_variable_decl = Node.is_child_of('variable_declaration', node)
        local indent = is_variable_decl and '      ' or ''
        local new = source:gsub(',%s*',',\n'..indent)
        Node.replace(node, new)
        Node.goto_node(node)
        if is_variable_decl then Node.trim_line_end(node) end
      end,
      join = function(node)
        local source = get_node_text(node, 0)
        local next = source:gsub('%s+', ' ')
        Node.replace(node, next)
        Node.goto_node(node)
      end
    },

  },

}
