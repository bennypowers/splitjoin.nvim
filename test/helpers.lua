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

function M.make_suite(lang, name, input, expected, go_to)
  local assert = require 'luassert'
  local splitjoin = require'splitjoin'

  function test()
    describe('splits', function()
        local bufnr

        local function create ()
        if not bufnr then
          bufnr = vim.api.nvim_create_buf(true, false)
          vim.api.nvim_win_set_buf(0, bufnr)
          vim.opt.filetype = lang
          local lines = vim.split(input, '\n', { plain = true, trimempty = false })
          vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, lines)
          if type(go_to) == 'string' then
            vim.cmd.norm('f'..go_to)
          elseif type(go_to) == 'table' then
            vim.api.nvim_win_set_cursor(0, go_to)
          end
        end
        end

        local function destroy()
          vim.api.nvim_buf_delete(bufnr, { force = true })
          bufnr = nil
        end

      before_each(create)
      after_each(destroy)

      it('as expected', function()
        splitjoin.split()
        assert.same(expected, M.get_buf_text(bufnr))
      end)
      describe('and rejoins', function()
        it('as expected', function()
          splitjoin.split()
          splitjoin.join()
          assert.same(input, M.get_buf_text(bufnr))
        end)
      end)
    end)
  end

  if (#name) then
    describe(name, test)
  else
    test()
    end
end

return M

