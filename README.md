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
    default_indent = '  ', -- default
    languages = {}, -- see Options
  },
}
```

## 🎁 Options

There are currently two options, the global `default_indent` serves as a 
fallback indent when a language does not have an indent configured. The 
`languages` table lets you specify or modify language rules. Each language table 
contains an `options` key which can have the following members:

| name                | type                  | description                                             |
| ----                | ----                  | -----------                                             |
| `default_indent`    | string                | indent to apply when splitting                          |
| `pad`               | table<string, bool>   | pad these node types with a single space when joining   |

Table values map node type names to bool or string. For example, these options 
for CSS ensure that blocks are padded when joined, and indented by two spaces 
when split.

```lua
---@return SplitjoinLanguageConfig
return {
  options = {
    default_indent = '  ',
    pad = {
      block = true,
    },
  }
}
```

In addition, a language table can specify the following config, which will be 
overridden by the defaults:

| name                | type                  | description                                             |
| ----                | ----                  | -----------                                             |
| `no_trailing_comma` | table<string, bool>   | remove trailing commas when splitting these             |
| `separators`        | table<string, string> | use this string as separator when operating             | operating  |

This is really only useful when [adding your own language](#adding-a-language).

### Default Options

```lua
local DEFAULT_OPTIONS = {
  default_indent = '  ',
  languages = {
    lua = {
      default_indent = '  ',
      pad = {
        table_constructor = true,
      },
    },
    ecmascript = {
      default_indent = '  ',
      pad = {
        object = true,
      },
    },
    css = {
      pad = {
        block = true,
      },
    },
    javascript = {
      extends = 'ecmascript',
    },
    typescript = {
      extends = 'ecmascript',
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

- **ecmascript**: object, array, params, arguments
- **lua**: table, params, arguments, variable_lists
- **css**: rules (blocks)

## TODO:
- **HTML**: deeply prettify children
- **${lang}**: things
- Tests


[vmp]: https://github.com/t9md/atom-vim-mode-plus
[sjv]: https://github.com/AndrewRadev/splitjoin.vim
[treesj]: https://github.com/Wansmer/treesj
[tna]: https://github.com/CKolkey/ts-node-action/

