local Node = require("splitjoin.util.node")

local M = {}

---@param node TSNode
---@param options SplitjoinLanguageOptions
function M.split_struct(node, options)
  local indent = options.default_indent or "  "
  local open, close = unpack(options.surround or {})
  local lines = {}

  table.insert(lines, open .. "\n")

  for child in node:iter_children() do
    if child:type() == "field_declaration" then
      local text = vim.trim(Node.get_text(child))
      table.insert(lines, indent .. text .. "\n")
    end
  end

  table.insert(lines, close)
  Node.replace(node, table.concat(lines, ""))
  Node.goto_node(node)
end

---@param node TSNode
---@param options SplitjoinLanguageOptions
function M.join_struct(node, options)
  local open, close = unpack(options.surround or {})
  local padding = options.padding or ""
  local parts = {}

  for child in node:iter_children() do
    if child:type() == "field_declaration" then
      local text = vim.trim(Node.get_text(child))
      if text:match(".*,%s*$") then
        text = text:gsub(",%s*$", "")
      end
      table.insert(parts, text)
    end
  end

  local final_string = open .. padding .. " " .. table.concat(parts, "; ") .. " " .. padding .. close
  Node.replace(node, final_string)
  Node.goto_node(node)
end

return M