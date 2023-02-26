local Node = require'splitjoin.util.node'

---@type SplitjoinLanguageOptions
return {

  nodes = {

    arguments = {
      surround = { '(', ')' },
      separator = ',',
      trailing_separator = false,
      split = Node.split,
      join = Node.join,
    },

    if_statement = {
      trailing_separator = false,
      surround = { 'if', 'end' },
      split = function(node, options)
        local indent = options.default_indent or '  '
        local lines = {}
        for child in node:iter_children() do
          local type = child:type()
          if type == 'if' then
            table.insert(lines, 'if '..Node.get_text(child:next_sibling())..' then\n')
          elseif type == 'end' then
            table.insert(lines, '\nend')
          elseif type == 'block' then
            table.insert(lines, indent .. vim.trim(Node.get_text(child)))
          elseif type == 'elseif_statement' or type == 'else_statement' then
            for grandchild in child:iter_children() do
              local gctype = grandchild:type()
              if gctype == 'elseif' then
                table.insert(lines, '\nelseif '..Node.get_text(grandchild:next_sibling())..' then\n')
              elseif gctype == 'else' then
                table.insert(lines, '\nelse\n')
              elseif gctype == 'block' then
                local line = indent .. vim.trim(Node.get_text(grandchild))
                table.insert(lines, line)
              end
            end
          end
        end
        Node.replace(node, table.concat(lines, ''))
        Node.goto_node(node)
      end,
      join = function(node)
        local replacement = ''
        local function append(s, t) replacement = replacement .. s .. (t or '') end
        for child in node:iter_children() do
          local type = child:type()
          if type == 'if' then
            append('if '..Node.get_text(child:next_sibling())..' then ')
          elseif type == 'block' then
            append(Node.get_text(child), ' ')
          elseif type == 'elseif_statement' or type == 'else_statement' then
            for grandchild in child:iter_children() do
              local gctype = grandchild:type()
              if gctype == 'elseif' then
                append('elseif '..Node.get_text(grandchild:next_sibling())..' then', ' ')
              elseif gctype == 'else' then
                append('else', ' ')
              elseif gctype == 'block' then
                append(vim.trim(Node.get_text(grandchild)), ' ')
              end
            end
          elseif type == 'end' then
            append('end')
          end
        end
        Node.replace(node, replacement)
        Node.goto_node(node)
      end
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
        local source = vim.treesitter.get_node_text(node, 0)
        local is_variable_decl = Node.is_child_of('variable_declaration', node)
        local indent = is_variable_decl and '      ' or ''
        local new = source:gsub(',%s*',',\n'..indent)
        Node.replace(node, new)
        Node.goto_node(node)
        if is_variable_decl then Node.trim_line_end(node) end
      end,
      join = function(node)
        local source = vim.treesitter.get_node_text(node, 0)
        local next = source:gsub('%s+', ' ')
        Node.replace(node, next)
        Node.goto_node(node)
      end
    },

  },

}
