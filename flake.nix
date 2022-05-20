{
  description = "grenade";

  inputs = {

    haedosa.url = "github:haedosa/flakes";
    nixpkgs.follows = "haedosa/nixpkgs";
    flake-utils.follows = "haedosa/flake-utils";

    haskellNix.url = "github:input-output-hk/haskell.nix";
    haskellNix.inputs.nixpkgs.follows = "haedosa/nixpkgs";

  };

  outputs =
    inputs@{ self, nixpkgs, flake-utils, ... }:
    {
      overlay = nixpkgs.lib.composeManyExtensions [
        inputs.haskellNix.overlay
        (import ./overlay.nix)
      ];
    } // flake-utils.lib.eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;
          inherit (inputs.haskellNix) config;
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
