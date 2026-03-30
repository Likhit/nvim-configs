# Neovim IDE Configuration

A minimal Neovim (0.11+) configuration managed as a Nix flake. Prioritizes understanding over convenience — reimplements what's feasible, installs what's genuinely complex.

## Features

- **Completion** — blink.cmp with LSP, buffer, path, snippet, and cmdline sources
- **Fuzzy finder** — fzf-lua for files, grep, buffers, git status, LSP symbols, keymaps, commands
- **LSP** — 8 language servers via native 0.11 `vim.lsp.config()`/`vim.lsp.enable()` (no nvim-lspconfig)
- **TreeSitter** — syntax highlighting via Neovim's built-in API with Nix-installed grammars
- **Statusline** — custom: mode, git branch, Nerd Font icons, filename, LSP health status, diagnostics, line:col
- **LSP health** — detects unresponsive servers with periodic pings, `:LspReload` to restart
- **Sessions** — per-project session save/restore with welcome screen on startup
- **Terminal** — `Ctrl+`` toggles a bottom terminal panel
- **Autopairs** — auto-close `()` `[]` `{}` `""` `''` `` ` ``

## Languages

Markdown, C/C++, Python, JavaScript/TypeScript, HTML/CSS, Nix, Lua.

## Installation

### As a home-manager module (production)

```nix
# flake.nix inputs
inputs.neovim-config.url = "github:Likhit/nvim-configs";

# home-manager config
imports = [ inputs.neovim-config.homeManagerModules.default ];
neovim-ide.enable = true;
```

This symlinks the Lua config to `~/.config/nvim/`, installs plugins into the pack path, and puts LSP servers + CLI tools on PATH.

### Development

```bash
cd nvim-configs
# direnv activates automatically: sets NVIM_APPNAME=nvim-dev, symlinks config
nvim  # uses this repo's config
```

Outside this directory, `nvim` uses your production config as normal.

## Keybindings

Leader key: **Space**

### Fuzzy finder (`<leader>f`)

| Key | Action |
|-----|--------|
| `ff` | Find files |
| `fg` | Live grep |
| `fb` | Buffers |
| `fo` | Recent files |
| `fw` | Grep word under cursor |
| `fv` | Grep visual selection |
| `fc` | Changed files (git status) |
| `fd` | Document diagnostics |
| `fs` | Document symbols (LSP) |
| `fl` | LSP references |
| `fk` | Keymaps |
| `f:` | Commands |
| `fr` | Resume last search |

### Completion (insert mode)

| Key | Action |
|-----|--------|
| `Tab` / `S-Tab` | Navigate items / snippet placeholders |
| `Enter` | Accept completion |
| `C-Space` | Trigger / toggle docs |
| `C-e` | Dismiss |
| `C-b` / `C-f` | Scroll docs |

### General

| Key | Action |
|-----|--------|
| `C-h/j/k/l` | Window navigation |
| `C-arrows` | Window resize |
| `C-s` | Save |
| `C-`` ` | Toggle terminal |
| `Esc Esc` | Exit terminal mode |
| `K` | Hover documentation (LSP) |
| `gd` | Go to definition |
| `grn` | Rename symbol |
| `grr` | Go to references |
| `gra` | Code actions |

### Session commands

| Command | Action |
|---------|--------|
| `:SessionSave` | Save current session |
| `:SessionQuit` | Save and quit all |
| `:LspReload` | Restart stuck LSP servers |

## Project structure

```
init.lua                    Entry point
lua/
  config/
    options.lua             Vim options
    keymaps.lua             Key bindings
    autocmds.lua            Autocommands
  plugins/
    treesitter.lua          TreeSitter highlighting
    lsp.lua                 LSP server setup
    cmp.lua                 Completion (blink.cmp)
    fzf.lua                 Fuzzy finder (fzf-lua)
  custom/
    statusline.lua          Custom statusline
    lsp_status.lua          LSP health monitoring
    autopairs.lua           Auto-close brackets/quotes
    sessions.lua            Session management
    welcome_screen.lua      Startup dashboard
lsp/                        Per-server LSP configs
  clangd.lua, pyright.lua, lua_ls.lua, ...
nix/
  module.nix                Home-manager module
  plugins.nix               Plugin list
  lsp-servers.nix           LSP server packages
```
