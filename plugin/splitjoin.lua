if vim.g.loaded_splitjoin then return end
vim.g.loaded_splitjoin = true

vim.keymap.set('n', '<Plug>(SplitjoinSplit)', function()
  require('splitjoin').split()
end, { desc = 'Split the object under cursor' })

vim.keymap.set('n', '<Plug>(SplitjoinJoin)', function()
  require('splitjoin').join()
end, { desc = 'Join the object under cursor' })

vim.keymap.set('n', '<Plug>(SplitjoinToggle)', function()
  require('splitjoin').toggle()
end, { desc = 'Toggle split/join the object under cursor' })

vim.api.nvim_create_user_command('SplitjoinSplit', function()
  require('splitjoin').split()
end, { desc = 'Split the object under cursor' })

vim.api.nvim_create_user_command('SplitjoinJoin', function()
  require('splitjoin').join()
end, { desc = 'Join the object under cursor' })

vim.api.nvim_create_user_command('SplitjoinToggle', function()
  require('splitjoin').toggle()
end, { desc = 'Toggle split/join the object under cursor' })
