local M = {}

local tmpfiles = {}

function M.root(root)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function M.read_lines(path)
  if not file_exists(path) then return {} end
  local lines = {}
  for line in io.lines(path) do
    lines[#lines + 1] = line
  end
  return lines
end

function M.skip(lang, name, fixture, split_expected, go_to)

end

function M.get_buf_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {}), '\n')
end

function M.get_char_at_cursor()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char = vim.api.nvim_get_current_line():sub(col+1,col+1)
  return char
end

function M.cleanup_tmpfiles()
  for _, file in ipairs(tmpfiles) do
    os.remove(file)
  end
  tmpfiles = {}
end

local function log_cursor_position_in_file(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)

  local output = {}

  -- Log cursor node info just before join
  local node = vim.treesitter.get_node({bufnr = bufnr, pos = {row - 1, col}, ignore_injections = false})
  if node then
    -- local lang = node:tree():root():type or "unknown"
    table.insert(output, "Treesitter node at cursor")
    table.insert(output, "  Type:      " .. node:type())
    -- table.insert(output, "  Lang:      " .. lang)
    table.insert(output, "  Text:      "..require'splitjoin.util.node'.get_text(node))
  else
    table.insert(output, "No Treesitter node at cursor")
  end

  for i = math.max(1, row - 4), row do
    table.insert(output, lines[i])
  end

  table.insert(output, string.rep(" ", col) .. "^ -- cursor here")

  return table.concat(output, "\n")
end

local function normalize(s)
  return (s or ""):gsub("%s+$", "")
end

local lang_ext = {
  css = "css",
  js  = "js",
  javascript = "js",
  ts  = "ts",
  typescript = "ts",
  go  = "go",
  json = "json",
  html = "html",
  lua = "lua",
  py  = "py",
  python = "py",
  md  = "md",
  markdown = "md",
  -- add more as needed
}

local function setup_buffer(content, lang, go_to)
  local ext = lang_ext[lang] or "txt"
  local tmpname = "/tmp/test_" .. tostring(os.time()) .. "_" .. tostring(math.random(1e8, 1e9-1)) .. "."..ext
  local f = assert(io.open(tmpname, "w"))
  f:write(content)
  f:close()
  table.insert(tmpfiles, tmpname)

  vim.cmd("edit " .. tmpname)
  vim.bo.filetype = lang  -- Set filetype before any autocommands!
  vim.cmd("doautocmd BufRead")
  vim.cmd("doautocmd FileType")
  vim.cmd("doautocmd Syntax")
  vim.cmd("redraw")
  vim.wait(100)

  local bufnr = vim.api.nvim_get_current_buf()

  local parser = vim.treesitter.get_parser(bufnr, lang)
  if parser then parser:parse() end
  vim.wait(100)

  if type(go_to) == 'string' then
    vim.fn.search(go_to)
  elseif type(go_to) == 'table' then
    vim.api.nvim_win_set_cursor(0, go_to)
  end

  return bufnr
end

---@param lang string language name
---@param name string suite name
---@param input string code to operate on

---@param expected string expected result
---@param go_to string|number[] go_to result
function M.make_suite(lang, name, input, expected, go_to)
  local assert = require 'luassert'
  local splitjoin = require'splitjoin'

local function test_fn()
    describe('splits', function()
      after_each(M.cleanup_tmpfiles)
      it('as expected', function()
        local bufnr = setup_buffer(input, lang, go_to)
        local before_log = log_cursor_position_in_file(bufnr)

        splitjoin.split()
        local after_log = log_cursor_position_in_file(bufnr)

        local success, result = pcall(assert.same, normalize(expected), normalize(M.get_buf_text(bufnr)))

        if not success then
          print("--- Before split ---")
          print(before_log)
          print("--- After split ---")
          print(after_log)
          error(result)
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
      end)
      it('and rejoins as expected', function()
        local bufnr = setup_buffer(input, lang, go_to)
        local before_log = log_cursor_position_in_file(bufnr)
        splitjoin.split()
        local after_split_log = log_cursor_position_in_file(bufnr)
        splitjoin.join()
        local after_join_log = log_cursor_position_in_file(bufnr)

        local success, result = pcall(assert.same, normalize(input), normalize(M.get_buf_text(bufnr)))

        if not success then
          print("--- Before split ---")
          print(before_log)
          print("--- After split ---")
          print(after_split_log)
          print("--- After join ---")
          print(after_join_log)
          error(result)
        end

        vim.api.nvim_buf_delete(bufnr, { force = true })
      end)
    end)
  end

  if (#name > 0) then
    describe(name, test_fn)
  else
    test_fn()
  end
end

return M
