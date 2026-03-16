# Returns a list of Neovim plugin derivations from nixpkgs.
# Plugins and colorschemes will be added in later phases.
{ pkgs }:

with pkgs.vimPlugins; [
  # -- Colorschemes (Phase 3) --
  # -- TreeSitter (Phase 4) --
  # -- Completion (Phase 6) --
  # -- Git signs (Phase 7) --
]
