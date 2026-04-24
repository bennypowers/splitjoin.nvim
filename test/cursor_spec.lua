local H = require'test.helpers'

local d = require'plenary.strings'.dedent

describe('cursor position', function()

  after_each(H.cleanup_tmpfiles)

  local splitjoin = require'splitjoin'

  -- SPLIT: cursor col should clamp to shortened first line

  describe('split clamps cursor col', function()

    it('lua table', function()
      -- local t = { a = 1, b = 2, c = 3 }
      --                  ^ col 17 (comma)
      -- after split, line 1 = "local t = {" (11 chars, cols 0-10)
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 17})
      splitjoin.split()
      assert.same({1, 10}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua function args', function()
      -- call(a, b, c)
      --       ^ col 6 (comma)
      -- after split, line 1 = "call(" (5 chars, cols 0-4)
      local bufnr = H.setup_buffer('call(a, b, c)\n', 'lua', {1, 6})
      splitjoin.split()
      assert.same({1, 4}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('typescript union', function()
      -- type A = 1|2|3;
      --           ^ col 10 (first pipe)
      -- after split, line 1 = "type A =" (8 chars, cols 0-7)
      local bufnr = H.setup_buffer('type A = 1|2|3;\n', 'typescript', {1, 10})
      splitjoin.split()
      assert.same({1, 7}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('go struct', function()
      -- type User struct { Name string; Age int; Email string }
      --                    ^ col 19 (N of Name)
      -- after split, line 1 = "type User struct {" (18 chars, cols 0-17)
      local bufnr = H.setup_buffer('type User struct { Name string; Age int; Email string }\n', 'go', {1, 19})
      splitjoin.split()
      assert.same({1, 17}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('javascript object', function()
      -- { one: 1, two: 2, three: 3 }
      --         ^ col 8 (comma)
      -- after split, line 1 = "{" (1 char, col 0)
      local bufnr = H.setup_buffer('{ one: 1, two: 2, three: 3 }\n', 'javascript', {1, 8})
      splitjoin.split()
      assert.same({1, 0}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('json object', function()
      -- { "one": 1, "two": 2, "three": 3 }
      --           ^ col 10 (comma)
      -- after split, line 1 = "{" (1 char, col 0)
      local bufnr = H.setup_buffer('{ "one": 1, "two": 2, "three": 3 }\n', 'json', {1, 10})
      splitjoin.split()
      assert.same({1, 0}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- SPLIT: cursor preserved when position is within bounds of new line

  describe('split preserves cursor when within bounds', function()

    it('html attrs — cursor on first attribute', function()
      -- <a id="a" href="#">Hi</a>
      --    ^ col 3 (i of id)
      -- after split, line 1 still has id attr, col 3 within bounds
      local bufnr = H.setup_buffer('<a id="a" href="#">Hi</a>\n', 'html', {1, 3})
      splitjoin.split()
      assert.same({1, 3}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua table — cursor at opening brace', function()
      -- local t = { a = 1, b = 2, c = 3 }
      --           ^ col 10 ({)
      -- after split, line 1 = "local t = {" — col 10 within bounds
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 10})
      splitjoin.split()
      assert.same({1, 10}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- JOIN: split first, reposition cursor, then join
  -- This mirrors real usage and ensures the split form matches what join expects

  describe('join after split', function()

    it('lua table — comma on row 2 clamps to row 1', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 17})
      splitjoin.split()
      vim.fn.search(',')
      splitjoin.join()
      assert.same({1, 7}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('typescript union — pipe on row 2 clamps to row 1', function()
      local bufnr = H.setup_buffer('type A = 1|2|3;\n', 'typescript', {1, 10})
      splitjoin.split()
      vim.fn.search('|')
      splitjoin.join()
      assert.same({1, 0}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('html attrs — href on row 2 clamps to row 1', function()
      local bufnr = H.setup_buffer('<a id="a" href="#">Hi</a>\n', 'html', {1, 3})
      splitjoin.split()
      vim.fn.search('i')
      splitjoin.join()
      assert.same({1, 14}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('go struct — brace on row 1 stays on row 1', function()
      local bufnr = H.setup_buffer('type User struct { Name string; Age int; Email string }\n', 'go', {1, 19})
      splitjoin.split()
      vim.fn.search('{')
      splitjoin.join()
      assert.same({1, 17}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('javascript object — comma on row 2 clamps to row 1', function()
      local bufnr = H.setup_buffer('{ one: 1, two: 2, three: 3 }\n', 'javascript', {1, 8})
      splitjoin.split()
      vim.fn.search(',')
      splitjoin.join()
      assert.same({1, 8}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- JOIN: cursor col preserved when row doesn't change

  describe('join preserves cursor col on row 1', function()

    it('lua table — cursor on opening brace stays', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 10})
      splitjoin.split()
      vim.api.nvim_win_set_cursor(0, {1, 10})
      splitjoin.join()
      assert.same({1, 10}, vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

end)
