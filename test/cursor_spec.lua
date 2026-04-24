local H = require'test.helpers'

local d = require'plenary.strings'.dedent

describe('cursor position', function()

  after_each(H.cleanup_tmpfiles)

  local tmpfiles = {}

  local lang_ext = {
    lua = 'lua', typescript = 'ts', html = 'html',
    go = 'go', javascript = 'js', python = 'py',
    json = 'json', css = 'css',
  }

  local function setup_buffer(content, lang, cursor_pos)
    local ext = lang_ext[lang] or 'txt'
    local tmpname = '/tmp/test_cursor_' .. tostring(os.time()) .. '_' .. tostring(math.random(1e8, 1e9-1)) .. '.' .. ext
    local f = assert(io.open(tmpname, 'w'))
    f:write(content)
    f:close()
    table.insert(tmpfiles, tmpname)

    vim.cmd('edit ' .. tmpname)
    vim.bo.filetype = lang
    vim.cmd('doautocmd BufRead')
    vim.cmd('doautocmd FileType')
    vim.cmd('doautocmd Syntax')
    vim.cmd('redraw')
    vim.wait(100)

    local bufnr = vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(bufnr, lang)
    if parser then parser:parse() end
    vim.wait(100)

    vim.api.nvim_win_set_cursor(0, cursor_pos)
    return bufnr
  end

  local splitjoin = require'splitjoin'

  -- SPLIT: cursor col should clamp to shortened first line

  describe('split clamps cursor col', function()

    it('lua table', function()
      -- local t = { a = 1, b = 2, c = 3 }
      --                  ^ col 17 (comma)
      -- after split, line 1 = "local t = {" (11 chars, cols 0-10)
      local bufnr = setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 17})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(1, cursor[1])
      assert.same(10, cursor[2])
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua function args', function()
      -- call(a, b, c)
      --       ^ col 6 (comma)
      -- after split, line 1 = "call(" (5 chars, cols 0-4)
      local bufnr = setup_buffer('call(a, b, c)\n', 'lua', {1, 6})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(1, cursor[1])
      assert.same(4, cursor[2])
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('typescript union', function()
      -- type A = 1|2|3;
      --           ^ col 10 (first pipe)
      -- after split, line 1 = "type A =" (8 chars, cols 0-7)
      local bufnr = setup_buffer('type A = 1|2|3;\n', 'typescript', {1, 10})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(1, cursor[1])
      assert.same(7, cursor[2])
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('go struct', function()
      -- type User struct { Name string; Age int }
      --                  ^ col 18 (open brace... actually let me find comma)
      -- go struct uses ';' separator, cursor on '{'
      -- after split, line 1 = "type User struct {" (18 chars, cols 0-17)
      -- cursor at {1, 20} (on 'N') should clamp to {1, 17}
      local bufnr = setup_buffer('type User struct { Name string; Age int; Email string }\n', 'go', {1, 19})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(1, cursor[1])
      assert.same(17, cursor[2])
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('javascript object', function()
      -- { one: 1, two: 2, three: 3 }
      --         ^ col 8 (comma)
      -- after split, line 1 = "{" (1 char, col 0)
      local bufnr = setup_buffer('{ one: 1, two: 2, three: 3 }\n', 'javascript', {1, 8})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(1, cursor[1])
      assert.same(0, cursor[2])
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('json object', function()
      -- { "one": 1, "two": 2, "three": 3 }
      --           ^ col 10 (comma)
      -- after split, line 1 = "{" (1 char, col 0)
      local bufnr = setup_buffer('{ "one": 1, "two": 2, "three": 3 }\n', 'json', {1, 10})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same(1, cursor[1])
      assert.same(0, cursor[2])
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- SPLIT: cursor preserved when position is within bounds of new line

  describe('split preserves cursor when within bounds', function()

    it('html attrs — cursor on first attribute', function()
      -- <a id="a" href="#">Hi</a>
      --    ^ col 3 (i of id)
      -- after split, line 1 = '<a id="a"' (9 chars, cols 0-8)
      -- col 3 is within bounds, no clamping
      local bufnr = setup_buffer('<a id="a" href="#">Hi</a>\n', 'html', {1, 3})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same({1, 3}, cursor)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua table — cursor at opening brace', function()
      -- local t = { a = 1, b = 2, c = 3 }
      --           ^ col 10 ({)
      -- after split, line 1 = "local t = {" (11 chars, cols 0-10)
      -- col 10 is within bounds
      local bufnr = setup_buffer('local t = { a = 1, b = 2, c = 3 }\n', 'lua', {1, 10})
      splitjoin.split()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same({1, 10}, cursor)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- JOIN: cursor row clamps when lines are removed

  describe('join clamps cursor', function()

    it('lua table — cursor does not advance past original position', function()
      local input = d[[
        local t = {
          a = 1,
          b = 2,
          c = 3,
        }
      ]]
      local bufnr = setup_buffer(input, 'lua', {3, 2})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert(cursor[1] <= 3, 'row should not exceed original')
      assert(cursor[2] <= 2, 'col should not exceed original')
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('lua function args — cursor does not advance past original position', function()
      local input = d[[
        call(
          a,
          b,
          c
        )
      ]]
      local bufnr = setup_buffer(input, 'lua', {3, 2})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert(cursor[1] <= 3, 'row should not exceed original')
      assert(cursor[2] <= 2, 'col should not exceed original')
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('typescript union — cursor does not advance past original position', function()
      local input = d[[
        type A =
          | 1
          | 2
          | 3;
      ]]
      local bufnr = setup_buffer(input, 'typescript', {2, 2})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert(cursor[1] <= 2, 'row should not exceed original')
      assert(cursor[2] <= 2, 'col should not exceed original')
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('html attrs — cursor does not advance past original position', function()
      local input = d[[
        <a id="a"
            href="#">Hi</a>
      ]]
      local bufnr = setup_buffer(input, 'html', {2, 4})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert(cursor[1] <= 2, 'row should not exceed original')
      assert(cursor[2] <= 4, 'col should not exceed original')
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('go struct — cursor does not advance past original position', function()
      local input = d[[
        type User struct {
          Name string
          Age int
          Email string
        }
      ]]
      local bufnr = setup_buffer(input, 'go', {2, 2})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert(cursor[1] <= 2, 'row should not exceed original')
      assert(cursor[2] <= 2, 'col should not exceed original')
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    it('javascript object — cursor does not advance past original position', function()
      local input = d[[
        {
          one: 1,
          two: 2,
          three: 3,
        }
      ]]
      local bufnr = setup_buffer(input, 'javascript', {3, 2})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert(cursor[1] <= 3, 'row should not exceed original')
      assert(cursor[2] <= 2, 'col should not exceed original')
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

  -- JOIN: cursor col preserved when row doesn't change

  describe('join preserves cursor col on row 1', function()

    it('lua table — cursor on opening brace stays', function()
      local input = d[[
        local t = {
          a = 1,
          b = 2,
          c = 3,
        }
      ]]
      local bufnr = setup_buffer(input, 'lua', {1, 10})
      splitjoin.join()
      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.same({1, 10}, cursor)
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

  end)

end)
