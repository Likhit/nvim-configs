# Returns a list of LSP server packages from nixpkgs.
{ pkgs }:

with pkgs; [
  marksman                      # Markdown
  clang-tools                   # C/C++ (clangd)
  pyright                       # Python
  typescript-language-server    # JS/TS/TSX
  vscode-langservers-extracted  # HTML, CSS, JSON
  nil                           # Nix
  lua-language-server           # Lua
]
