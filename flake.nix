{
  description = "Neovim IDE configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      homeManagerModules.default = import ./nix/module.nix { inherit self; };

      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          plugins = import ./nix/plugins.nix { inherit pkgs; };
        in
        {
          nvim-plugins = pkgs.linkFarm "nvim-plugins" (map (plugin: {
            name = "start/${plugin.pname or plugin.name}";
            path = plugin;
          }) plugins);
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lspServers = import ./nix/lsp-servers.nix { inherit pkgs; };
        in
        {
          default = pkgs.mkShell {
            packages = lspServers ++ (with pkgs; [
              fzf  # fuzzy finder (used by fzf-lua)
              fd   # file finder (used by fzf-lua)
            ]);
            NVIM_PLUGINS = self.packages.${system}.nvim-plugins;
          };
        }
      );
    };
}
