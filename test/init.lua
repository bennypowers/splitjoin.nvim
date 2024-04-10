---@license copyright folke Apache 2.0
---@see https://github.com/folke/lazy.nvim/blob/7339145a223dab7e7ddccf0986ffbf9d2cb804e8/tests/init.lua
local M = {}
local H = require'test.helpers'

---@param plugin string
function M.load(plugin)
  local name = plugin:match'.*/(.*)'
  local package_root = H.root'.test/site/pack/deps/start/'
  if not vim.loop.fs_stat(package_root .. name) then
    print('Installing ' .. plugin)
    vim.fn.mkdir(package_root, 'p')
    vim.fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/' .. plugin .. '.git', package_root .. '/' .. name, })
  end
end

function M.setup()
  vim.cmd'set runtimepath=$VIMRUNTIME'
  vim.opt.runtimepath:append(H.root())
  vim.opt.packpath = { H.root'.test/site' }
  M.load'nvim-lua/plenary.nvim'
  M.load'nvim-treesitter/nvim-treesitter'

  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      'lua',
      'css',
      'json',
      'jsdoc',
      'javascript',
      'typescript',
      'html',
    },
    sync_install = true,
  }

  vim.env.XDG_CONFIG_HOME = H.root'.test/config'
  vim.env.XDG_DATA_HOME = H.root'.test/data'
  vim.env.XDG_STATE_HOME = H.root'.test/state'
  vim.env.XDG_CACHE_HOME = H.root'.test/cache'
end

M.setup()
