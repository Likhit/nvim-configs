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

  # -- TreeSitter (Phase 4) --
  # -- Completion (Phase 6) --
  # -- Git signs (Phase 7) --
]
