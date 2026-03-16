{
  description = "Neovim IDE configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      homeManagerModules.default = import ./nix/module.nix { inherit self; };

      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            shellHook = ''
              export NVIM_APPNAME="nvim-dev"
              ln -sfn "$(pwd)" "$HOME/.config/nvim-dev"
            '';
          };
        }
      );
    };
}
