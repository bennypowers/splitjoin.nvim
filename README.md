# 🪓🧷 splitjoin.nvim

Split or join list-like syntax constructs. like `g,` and `gj` from the venerable 
old [vim-mode-plus][vmp].

> looking for something more mature? [treesj][treesj]  
> looking for something more bramvim? [splitjoin.vim][sjv] 

## 🚚 Installation

```lua
return { 'bennypowers/splitjoin.nvim',
  lazy = true,
  keys = {
    { 'gj', function() require'splitjoin'.join() end, desc = 'Join the object under cursor' },
    { 'g,', function() require'splitjoin'.split() end, desc = 'Split the object under cursor' },
  },
  opts = {
    -- default_indent = '  ' -- default is two spaces
  },
}
```

## `split()`

Separate the construct under the cursor into multiple lines

Before:
```javascript
[1, 2, 3]
```
After:
```javascript
[
  1,
  2,
  3,
]
```

## `join()`

Join the construct under the cursor into a single line

Before:
```javascript
[
  1,
  2,
  3,
]
```
After:
```javascript
[1, 2, 3]
```

## Support

- **ecmascript/typescript**: object, array, params, arguments
- **lua**: table, params, arguments

## TODO:
- **HTML**: deeply prettify children
- **${lang}**: things
- Tests


## Prior Art
- [AndrewRadev/splitjoin.vim][sjv]
- [treesj][treesj]

[vmp]: https://github.com/t9md/atom-vim-mode-plus
[sjv]: https://github.com/AndrewRadev/splitjoin.vim
[treesj]: https://github.com/Wansmer/treesj

