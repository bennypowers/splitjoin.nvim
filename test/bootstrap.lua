package.path = './?.lua;./?/init.lua;' .. package.path
local Setup = require 'test.setup'

Setup.load 'nvim-lua/plenary.nvim'
Setup.load 'nvim-treesitter/nvim-treesitter'

Setup.setup()

local ts = require 'nvim-treesitter'
ts.install({
  'c',
  'cpp',
  'css',
  'go',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'nix',
  'python',
  'rust',
  'typescript',
  'yaml',
}):wait(60000)
