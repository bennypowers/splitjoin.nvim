local M = {}

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

local function log_cursor_position_in_file()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)

  local output = {}
  for i = math.max(1, row - 4), row do
    table.insert(output, lines[i])
  end

  table.insert(output, string.rep(" ", col) .. "^ -- cursor here")

  return table.concat(output, "\n")
end

---@param lang string language name
---@param name string suite name
---@param input string code to operate on

---@param expected string expected result
---@param go_to string|number[] go_to result
function M.make_suite(lang, name, input, expected, go_to)
  local assert = require 'luassert'
  local splitjoin = require'splitjoin'

  local function setup_buffer(content)
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.opt.filetype = lang
    local lines = vim.split(content, '\n', { plain = true, trimempty = false })
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, lines)
    if type(go_to) == 'string' then
      vim.fn.search(go_to)
    elseif type(go_to) == 'table' then
      vim.api.nvim_win_set_cursor(0, go_to)
    end
    return bufnr
  end

  local function test_fn()
    describe('splits', function()
      it('as expected', function()
        local bufnr = setup_buffer(input)
        local before_log = log_cursor_position_in_file()
        splitjoin.split()
        local after_log = log_cursor_position_in_file()

        local success, result = pcall(assert.same, expected, M.get_buf_text(bufnr))

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
        local bufnr = setup_buffer(input)
        local before_log = log_cursor_position_in_file()
        splitjoin.split()
        local after_split_log = log_cursor_position_in_file()
        splitjoin.join()
        local after_join_log = log_cursor_position_in_file()

        local success, result = pcall(assert.same, input, M.get_buf_text(bufnr))

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
