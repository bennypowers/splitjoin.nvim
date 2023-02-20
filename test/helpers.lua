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

function M.make_suite(lang, name, fixture, split_expected, sep)
  local assert = require 'luassert'
  local splitjoin = require'splitjoin'

  describe(name, function()
    before_each(function()
      bufnr = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_win_set_buf(0, bufnr)
      vim.opt.filetype = lang
      vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {fixture})
      vim.cmd.norm('f'..sep)
    end)
    after_each(function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
    it('splits', function()
      splitjoin.split()
      assert.same(split_expected,
                  table.concat(vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {}), '\n'))
    end)
    it('splits and joins', function()
      splitjoin.split()
      splitjoin.join()
      assert.same(fixture,
                  table.concat(vim.api.nvim_buf_get_text(bufnr, 0, 0, -1, -1, {}), '\n'))
    end)
  end)
end

return M

