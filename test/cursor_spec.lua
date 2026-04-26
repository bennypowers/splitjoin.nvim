local H = require'test.helpers'

describe('cursor position', function()

  after_each(H.cleanup_tmpfiles)

  local splitjoin = require'splitjoin'

  -- HOLD: cursor tracks character across split/join

  describe('hold — split tracks character', function()

    it('lua table comma', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 17})
      assert.same(',', H.get_char_at_cursor())
      splitjoin.split()
      assert.same(',', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua function args comma', function()
      local bufnr = H.setup_buffer('call(a, b, c)\n', 'lua', {1, 6})
      assert.same(',', H.get_char_at_cursor())
      splitjoin.split()
      assert.same(',', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('go struct field name', function()
      local bufnr = H.setup_buffer('type User struct { Name string; Age int; Email string }\n', 'go', {1, 19})
      assert.same('N', H.get_char_at_cursor())
      splitjoin.split()
      assert.same('N', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('javascript object comma', function()
      local bufnr = H.setup_buffer('{ one: 1, two: 2, three: 3 }\n', 'javascript', {1, 8})
      assert.same(',', H.get_char_at_cursor())
      splitjoin.split()
      assert.same(',', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('json object comma', function()
      local bufnr = H.setup_buffer('{ "one": 1, "two": 2, "three": 3 }\n', 'json', {1, 10})
      assert.same(',', H.get_char_at_cursor())
      splitjoin.split()
      assert.same(',', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('opening brace stays on opening brace', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2 }\n', 'lua', {1, 10})
      assert.same('{', H.get_char_at_cursor())
      splitjoin.split()
      assert.same('{', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('closing brace stays on closing brace', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2 }\n', 'lua', {1, 26})
      assert.same('}', H.get_char_at_cursor())
      splitjoin.split()
      assert.same('}', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('html attrs — cursor on first attribute', function()
      local bufnr = H.setup_buffer('<a id="a" href="#">Hi</a>\n', 'html', {1, 3})
      assert.same('i', H.get_char_at_cursor())
      splitjoin.split()
      assert.same('i', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- HOLD: split+join roundtrip

  describe('hold — roundtrip', function()

    it('lua table comma roundtrip', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 17})
      assert.same(',', H.get_char_at_cursor())
      splitjoin.split()
      assert.same(',', H.get_char_at_cursor())
      splitjoin.join()
      assert.same(',', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua function args comma roundtrip', function()
      local bufnr = H.setup_buffer('vim.print("foo", "bar")\n', 'lua', {1, 15})
      assert.same(',', H.get_char_at_cursor())
      splitjoin.split()
      assert.same(',', H.get_char_at_cursor())
      splitjoin.join()
      assert.same(',', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('opening brace roundtrip', function()
      local bufnr = H.setup_buffer('local t = { a = 1, b = 2 }\n', 'lua', {1, 10})
      assert.same('{', H.get_char_at_cursor())
      splitjoin.split()
      assert.same('{', H.get_char_at_cursor())
      splitjoin.join()
      assert.same('{', H.get_char_at_cursor())
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- HOLD: duplicate content — proves structural indexing, not char matching

  describe('hold — duplicate content', function()

    it('cursor on 2nd a in f(a, a, a) stays on 2nd a after split', function()
      -- f(a, a, a)
      --      ^ col 5 (2nd a)
      local bufnr = H.setup_buffer('f(a, a, a)\n', 'lua', {1, 5})
      assert.same('a', H.get_char_at_cursor())

      splitjoin.split()
      assert.same('a', H.get_char_at_cursor())

      -- verify it's the 2nd a, not the 1st — cursor should be on row 3
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(3, cursor[1])

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('cursor on 3rd 1 in table stays on 3rd 1 after split', function()
      -- local t = { 1, 1, 1 }
      --                   ^ col 18 (3rd 1)
      local bufnr = H.setup_buffer('local t = { 1, 1, 1 }\n', 'lua', {1, 18})
      assert.same('1', H.get_char_at_cursor())

      splitjoin.split()
      assert.same('1', H.get_char_at_cursor())

      -- verify it's the 3rd 1 — cursor should be on row 4
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(4, cursor[1])

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('roundtrip preserves position with duplicate args', function()
      -- f(x, x, x)
      --         ^ col 8 (3rd x)
      local bufnr = H.setup_buffer('f(x, x, x)\n', 'lua', {1, 8})
      assert.same('x', H.get_char_at_cursor())

      splitjoin.split()
      assert.same('x', H.get_char_at_cursor())

      splitjoin.join()
      assert.same('x', H.get_char_at_cursor())
      assert.same({1, 8}, vim.api.nvim_win_get_cursor(0))

      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

end)
