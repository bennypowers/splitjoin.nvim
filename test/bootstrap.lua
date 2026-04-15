package.path = './?.lua;./?/init.lua;' .. package.path
local Setup = require 'test.setup'

Setup.load 'nvim-lua/plenary.nvim'
Setup.load 'nvim-treesitter/nvim-treesitter'

Setup.setup()

local ts = require 'nvim-treesitter'
ts.install({
  'css',
  'go',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'python',
  'typescript',
}):wait(30000)
