# Takes `self` (the flake source) via the import in flake.nix.
# Returns a home-manager module function.
{ self }:

{ config, lib, pkgs, ... }:

let
  cfg = config.neovim-ide;
  plugins = import ./plugins.nix { inherit pkgs; };
  lspServers = import ./lsp-servers.nix { inherit pkgs; };
in
{
  options.neovim-ide = {
    enable = lib.mkEnableOption "Neovim IDE configuration";
  };

  config = lib.mkIf cfg.enable {
    # Symlink Lua config into ~/.config/nvim/
    xdg.configFile."nvim/init.lua".source = "${self}/init.lua";
    xdg.configFile."nvim/lua".source = "${self}/lua";
    xdg.configFile."nvim/lsp".source = "${self}/lsp";

    # Install plugins into the Neovim pack path
    xdg.dataFile = builtins.listToAttrs (map (plugin: {
      name = "nvim/site/pack/nix/start/${plugin.pname or plugin.name}";
      value = { source = "${plugin}"; };
    }) plugins);

    # Install LSP servers and CLI tools onto PATH
    home.packages = lspServers ++ (with pkgs; [
      fzf  # fuzzy finder (used by fzf-lua)
      fd   # file finder (used by fzf-lua)
    ]);
  };
}
