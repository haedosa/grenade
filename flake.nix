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
      flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let

        overlays = [
          inputs.haskellNix.overlay
          (import ./overlay.nix)
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (inputs.haskellNix) config;
        };

        flake = pkgs.grenade-project.flake {};

      in flake // (rec {
        defaultPackage = flake.packages."grenade:lib:grenade";
      })
    );

}
