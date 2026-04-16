if vim.g.loaded_splitjoin then return end
vim.g.loaded_splitjoin = true

vim.keymap.set('n', '<Plug>(SplitjoinSplit)', function()
  require('splitjoin').split()
end, { desc = 'Split the object under cursor' })

vim.keymap.set('n', '<Plug>(SplitjoinJoin)', function()
  require('splitjoin').join()
end, { desc = 'Join the object under cursor' })
