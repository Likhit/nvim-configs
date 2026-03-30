# CLAUDE.md — Guide for modifying this Neovim configuration

## What this project is

A Neovim 0.11+ IDE configuration managed as a Nix flake with a home-manager module. It uses native Neovim APIs wherever possible (no nvim-lspconfig, no nvim-treesitter plugin) and reimplements simple features in Lua rather than adding plugins.

## Architecture

### Entry point

`init.lua` loads modules in order. Load order matters:
1. `config/options` → `config/keymaps` → `config/autocmds` (vanilla Neovim setup)
2. `plugins/treesitter` (syntax highlighting)
3. `custom/statusline` + `custom/autopairs` (UI customizations)
4. `plugins/fzf` (fuzzy finder)
5. `plugins/cmp` (completion — must load before LSP)
6. `plugins/lsp` (LSP — calls `require("blink.cmp").get_lsp_capabilities()`, so cmp must be loaded first)
7. `custom/welcome_screen` (session dashboard — loads last, after VimEnter)
8. Colorscheme applied last

### Plugin management

Plugins are installed via Nix, not a Lua plugin manager. The flow:
- `nix/plugins.nix` — list of `pkgs.vimPlugins.*` derivations
- `nix/module.nix` — symlinks them into the Neovim pack path (`~/.local/share/nvim/site/pack/nix/start/`)
- Plugins are available at startup with no `require("lazy")` or similar

To add a new plugin: add it to `nix/plugins.nix`, create a config file in `lua/plugins/`, and `require()` it from `init.lua`.

### LSP setup

Uses Neovim 0.11's native API — no nvim-lspconfig:
- Per-server configs live in `lsp/<server>.lua` (e.g., `lsp/pyright.lua`)
- Each file returns a table with `cmd`, `filetypes`, `settings`
- `lua/plugins/lsp.lua` calls `vim.lsp.config("*", { capabilities })` then `vim.lsp.enable({...})`
- Server binaries are installed via `nix/lsp-servers.nix`

To add a new language server:
1. Add the package to `nix/lsp-servers.nix`
2. Create `lsp/<name>.lua` with `cmd`, `filetypes`, and `settings`
3. Add the name to the `vim.lsp.enable()` list in `lua/plugins/lsp.lua`

### TreeSitter

Uses Neovim's built-in `vim.treesitter` API — no nvim-treesitter plugin:
- Grammars are installed as `nvim-treesitter.grammarPlugins.*` in `nix/plugins.nix`
- `lua/plugins/treesitter.lua` enables highlighting via a FileType autocmd
- The `pcall` around `vim.treesitter.start` is intentional — some plugin filetypes (e.g., `blink-cmp-menu`) don't have parsers

To add a new grammar: add `nvim-treesitter.grammarPlugins.<lang>` to `nix/plugins.nix`.

### Custom modules (`lua/custom/`)

Reimplemented features, no external dependencies:
- `statusline.lua` — renders the statusline, defines mode/git/highlight config
- `lsp_status.lua` — tracks LSP lifecycle (starting → loading → ok → unresponsive), periodic health pings, `:LspReload` command. LSP filetypes are auto-detected from LspAttach events (no hardcoded list)
- `autopairs.lua` — simple insert-mode keymaps for bracket/quote auto-close
- `sessions.lua` — session save/restore using `mksession`. Sessions stored in `stdpath("data")/sessions/` as `<hash>.vim` + `<hash>.path` file pairs
- `welcome_screen.lua` — shown on `VimEnter` when no args. Lists sessions, handles create/open/delete

### Nix structure

- `flake.nix` — exposes `homeManagerModules.default`, `devShells.default`, and `packages.nvim-plugins`
- `nix/module.nix` — home-manager module: symlinks `init.lua`, `lua/`, `lsp/`; installs plugins and packages
- `nix/plugins.nix` — returns a list of plugin derivations
- `nix/lsp-servers.nix` — returns a list of LSP server packages
- `.envrc` — sets `NVIM_APPNAME=nvim-dev` for development isolation

The dev shell (`flake.nix` devShells) and the home-manager module (`nix/module.nix`) both need CLI tools like `fzf` and `fd`. Keep them in sync when adding new external tools.

## Key decisions and their rationale

- **blink.cmp over nvim-cmp** — built-in sources (LSP, buffer, path, snippets, cmdline), Rust SIMD fuzzy matching, fewer plugins to manage
- **fzf-lua over telescope** — better performance, fewer dependencies, built-in pickers, simpler config. Requires `fzf` and `fd` binaries on PATH
- **Native LSP over nvim-lspconfig** — Neovim 0.11 has `vim.lsp.config()`/`vim.lsp.enable()` built in
- **Native TreeSitter over nvim-treesitter plugin** — built-in `vim.treesitter.start()` with Nix-installed grammars
- **lua_ls workspace.library = { vim.env.VIMRUNTIME }** — scanning all plugins caused multi-minute indexing. Only the Neovim runtime is needed for `vim.*` API awareness
- **Session files use hash-based naming** — previous approaches using path encoding (`%`, `_`) caused Lua pattern matching bugs. Hash + companion `.path` file is unambiguous
- **No gitsigns, indent guides, or file explorer plugins** — `:Ex` (netrw) and `<leader>ff` (fzf-lua) cover file navigation; the other features weren't needed

## Common tasks

### Adding a new plugin
1. Add to `nix/plugins.nix`
2. Create `lua/plugins/<name>.lua` with setup/config
3. Add `require("plugins.<name>")` to `init.lua` (mind load order)
4. If it needs CLI tools, add them to both `flake.nix` devShell and `nix/module.nix` home.packages

### Adding a new language
1. Add grammar to `nix/plugins.nix`: `nvim-treesitter.grammarPlugins.<lang>`
2. Add LSP server to `nix/lsp-servers.nix`
3. Create `lsp/<server>.lua` with config
4. Add server name to `vim.lsp.enable()` in `lua/plugins/lsp.lua`
5. If non-standard indent, add a FileType autocmd in `lua/config/autocmds.lua`

### Changing the colorscheme
Edit the last line of `init.lua`: `vim.cmd.colorscheme("kanagawa")`. Available: kanagawa, catppuccin, tokyonight, gruvbox-material, rose-pine, monokai-pro, dracula.

### Adding keybindings
Add to `lua/config/keymaps.lua` for general bindings, or to the relevant `lua/plugins/*.lua` for plugin-specific bindings (e.g., fzf keymaps live in `lua/plugins/fzf.lua`).

## Files that are stubs (not implemented)

These files exist but only contain a comment placeholder:
- `lua/custom/explorer.lua` — file explorer (skipped, using netrw + fzf)
- `lua/custom/fuzzy.lua` — custom fuzzy finder (skipped, using fzf-lua)
- `lua/custom/indent_guides.lua` — indent guides (skipped)
- `lua/plugins/gitsigns.lua` — git signs (skipped)
