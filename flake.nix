{
  description = "grenade";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-19.03";
    flake-utils.url = "github:numtide/flake-utils/master";

  };

  outputs =
    inputs@{ self, nixpkgs, flake-utils, ... }:
    {
      overlays = [ (import ./overlay.nix) ];
      overlay = nixpkgs.lib.composeManyExtensions self.overlays;
    } // flake-utils.lib.eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;
          config = {};
          overlays = [ self.overlay ];
        };

      in rec {
        defaultPackage = pkgs.haskellPackages.grenade;
        devShell = import ./develop.nix { inherit pkgs; };

        apps = let
          ghcEnv = pkgs.haskellPackages.ghcWithPackages (p: [ p.grenade ]);
        in {
          jupyter = {
            type = "app";
            program = "${pkgs.jupyterlab}/bin/jupyter-lab";
          };
          ghci = {
            type = "app";
            program = "${ghcEnv}/bin/ghci";
          };
        };
        defaultApp = apps.ghci;
      }
    );

}
