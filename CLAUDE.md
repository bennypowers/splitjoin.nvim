# splitjoin.nvim

Treesitter-based split/join for Neovim. Split or join list-like syntax
constructs across 15+ languages.

## Development

- Run tests: `make test`
- Tests use plenary.nvim's busted runner with nvim-treesitter
- Test bootstrap installs parsers to `.test/site/`

## Architecture

- `plugin/splitjoin.lua` -- load guard, `<Plug>` mappings, user commands
- `lua/splitjoin.lua` -- public API (split, join, toggle, setup), operatorfunc for dot-repeat
- `lua/splitjoin/util/node.lua` -- Node.split/Node.join (default handlers), tree utilities
- `lua/splitjoin/util/options.lua` -- config merging, language auto-discovery from runtimepath
- `lua/splitjoin/util/handlers.lua` -- DefaultHandlers (string-based, unused by built-in languages)
- `lua/splitjoin/languages/<lang>/` -- per-language config (defaults.lua, options.lua, functions.lua)
- `queries/<lang>/splitjoin.scm` -- treesitter queries defining splittable nodes

## Adding a new language

1. Create `queries/<lang>/splitjoin.scm` with captures for target nodes
2. Create `lua/splitjoin/languages/<lang>/defaults.lua` with node configs
3. Add the parser to `test/bootstrap.lua`
4. Add the file extension to `test/helpers.lua` `lang_ext` table
5. Create `test/<lang>_spec.lua` with split/rejoin tests
6. **Update `README.md` Support section** with the new language and its constructs

For comma-separated surround-delimited constructs, only `surround` is needed --
`Node.split`/`Node.join` handle the rest. For non-standard constructs (e.g.
space-delimited Nix lists), write custom handlers in `functions.lua`.

## Rules

- Always update README.md when adding new features or languages
- Run `make test` before committing -- all tests must pass
- Prefer `require'...'` style (single quotes, no parens) for consistency
- `setup()` is optional -- the plugin must work with zero configuration
