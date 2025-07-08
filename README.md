# 🪓🧷 splitjoin.nvim

[![Number of users on dotfyle][dotfyle-badge]][dotfyle]

Split or join list-like syntax constructs. like `g,` and `gj` from the venerable 
old [vim-mode-plus][vmp].

> looking for something more...
>  - mature? [treesj][treesj]  
>  - generic? [ts-node-action][tna]  
>  - bramvim? [splitjoin.vim][sjv]  

## 🚚 Installation

```lua
return { 'bennypowers/splitjoin.nvim',
  lazy = true,
  keys = {
    { 'gj', function() require'splitjoin'.join() end, desc = 'Join the object under cursor' },
    { 'g,', function() require'splitjoin'.split() end, desc = 'Split the object under cursor' },
  },
}
```

## 🎁 Options

There are currently two options, the global `default_indent` serves as a 
fallback indent when a language does not have an indent configured. The 
`languages` table lets you specify or modify language rules. Each language table 
contains an `options` key which can have the following members:

| name                    | type                  | description                                         |
| ----                    | ----                  | -----------                                         |
| `default_indent`        | string                | indent to apply when splitting                      |
| `nodes`                 | table<string, table>  | options for this node                               |
| `nodes[name].padding`   | string                | padding to apply when joining                       |
| `nodes[name].sep_first` | boolean               | whether to place the separator first when splitting |

### Default Options

See `languages/*/options.lua`

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

- **ecmascript**: object, array, params, arguments
- **lua**: table, params, arguments, variable_lists
- **html**: tags, attributes
- **css**: rules (blocks)
- **go**: parameter lists, structs, return lists, arguments, slices, etc

[vmp]: https://github.com/t9md/atom-vim-mode-plus
[sjv]: https://github.com/AndrewRadev/splitjoin.vim
[treesj]: https://github.com/Wansmer/treesj
[tna]: https://github.com/CKolkey/ts-node-action/
[dotfyle]: https://dotfyle.com/plugins/bennypowers/splitjoin.nvim
[dotfyle-badge]: https://dotfyle.com/plugins/bennypowers/splitjoin.nvim/shield
