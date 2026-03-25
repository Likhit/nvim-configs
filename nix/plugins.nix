# Returns a list of Neovim plugin derivations from nixpkgs.
{ pkgs }:

with pkgs.vimPlugins; [
  # -- Colorschemes --
  catppuccin-nvim
  tokyonight-nvim
  gruvbox-material
  kanagawa-nvim
  rose-pine
  monokai-pro-nvim
  dracula-nvim

  # -- TreeSitter grammars (parser .so files only, no nvim-treesitter plugin) --
  nvim-treesitter.grammarPlugins.markdown
  nvim-treesitter.grammarPlugins.markdown_inline
  nvim-treesitter.grammarPlugins.c
  nvim-treesitter.grammarPlugins.cpp
  nvim-treesitter.grammarPlugins.python
  nvim-treesitter.grammarPlugins.javascript
  nvim-treesitter.grammarPlugins.typescript
  nvim-treesitter.grammarPlugins.tsx
  nvim-treesitter.grammarPlugins.html
  nvim-treesitter.grammarPlugins.css
  nvim-treesitter.grammarPlugins.nix
  nvim-treesitter.grammarPlugins.lua
  nvim-treesitter.grammarPlugins.json
  nvim-treesitter.grammarPlugins.yaml
  nvim-treesitter.grammarPlugins.bash

  # -- TreeSitter text objects (disabled until learned from tutorial) --
  # nvim-treesitter-textobjects

  # -- Completion (Phase 6) --
  # -- Git signs (Phase 7) --
]
