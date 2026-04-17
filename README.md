# 🪓🧷 splitjoin.nvim

[![Number of users on dotfyle][dotfyle-badge]][dotfyle]

Split or join list-like syntax constructs. like `g,` and `gj` from the venerable 
old [vim-mode-plus][vmp].

> looking for something more...
>  - mature? [treesj][treesj]  
>  - generic? [ts-node-action][tna]  
>  - bramvim? [splitjoin.vim][sjv]  

## 🚚 Installation

`setup()` is optional -- the plugin works out of the box with zero configuration.

```lua
vim.pack.add('bennypowers/splitjoin.nvim')
vim.keymap.set('n', 'gS', function() require'splitjoin'.toggle() end)
```

### `<Plug>` mappings

The plugin defines `<Plug>` mappings for use in your keymap config:

- `<Plug>(SplitjoinSplit)` -- split the construct under cursor
- `<Plug>(SplitjoinJoin)` -- join the construct under cursor
- `<Plug>(SplitjoinToggle)` -- auto-detect and toggle

### Commands

`:SplitjoinSplit`, `:SplitjoinJoin`, `:SplitjoinToggle`

## 🎛 API

| function                  | description                                         |
| ----                      | -----------                                         |
| `require'splitjoin'.split()`  | split the construct under cursor                |
| `require'splitjoin'.join()`   | join the construct under cursor                 |
| `require'splitjoin'.toggle()` | split if single-line, join if multi-line         |
| `require'splitjoin'.setup(opts)` | override default options (optional)           |

All operations support dot-repeat (`.`) and are grouped into a single undo 
entry.

## 🎁 Options

`setup()` is optional. You can also configure via `vim.g.splitjoin` (table or 
function returning a table) before or after the plugin loads:

```lua
vim.g.splitjoin = {
  languages = {
    html = {
      nodes = {
        attribute = { aligned = true },
      },
    },
  },
}
```

### Language options

| name                    | type                    | description                                         |
| ----                    | ----                    | -----------                                         |
| `default_indent`        | `string\|fun():string` | indent to apply when splitting                      |
| `nodes`                 | `table<string, table>`  | per-node-type options                               |
| `nodes[name].surround`  | `string[]`              | open/close delimiter pair                           |
| `nodes[name].separator` | `string`                | item separator (default: `','`)                     |
| `nodes[name].padding`   | `string`                | padding inside delimiters when joining              |
| `nodes[name].trailing_separator` | `boolean`      | keep trailing separator (default: `true`)           |
| `nodes[name].sep_first` | `boolean`               | place separator before items when splitting         |

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

- **ecmascript**: object, array, params, arguments, named imports
- **typescript**: unions, type params, type arguments, plus all ecmascript
- **lua**: table, params, arguments, variable lists, if/else, functions
- **html**: tags, attributes, children
- **css**: rules (blocks), function arguments, value lists
- **go**: parameter lists, structs, return lists, arguments, slices, maps
- **python**: parameters, arguments, lists, dictionaries, tuples, sets
- **json**: objects, arrays
- **jsdoc**: descriptions

### Third-party languages

Language modules are auto-discovered from the runtimepath. To add support for a 
new language, create `lua/splitjoin/languages/<lang>/defaults.lua` anywhere on 
your runtimepath. See existing language modules for examples.

[vmp]: https://github.com/t9md/atom-vim-mode-plus
[sjv]: https://github.com/AndrewRadev/splitjoin.vim
[treesj]: https://github.com/Wansmer/treesj
[tna]: https://github.com/CKolkey/ts-node-action/
[dotfyle]: https://dotfyle.com/plugins/bennypowers/splitjoin.nvim
[dotfyle-badge]: https://dotfyle.com/plugins/bennypowers/splitjoin.nvim/shield
