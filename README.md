# 🪓🧷 splitjoin.nvim

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
  opts = {
    -- default_indent = '  ' -- default is two spaces
  },
}
```

## 🎁 Options
| name                | type   | description                                  |
| ----                | ----   | -----------                                  |
| `default_indent`    | string | indent to apply when splitting               |
| `pad`               | *      | pad these with a single space when joining   |
| `no_trailing_comma` | *      | remove trailing commas when splitting these  |
| `separators`        | *      | use this string as separator when operating  |

`*` - Record<LanguageName, Record<NodeType, boolean>>

It's best to avoid configuring `no_trailing_comma` and `separators`. These 
options may be removed for 1.0.

### Default Options

```lua
local DEFAULT_OPTIONS = {
  default_indent = '  ',
  no_trailing_comma = {
    lua = {
      parameters = true,
      arguments = true,
    },
  },
  pad = {
    javascript = {
      object = true,
    },
  },
  separators = {
    css = {
      block = ';',
    },
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
[tna]: https://github.com/CKolkey/ts-node-action/

