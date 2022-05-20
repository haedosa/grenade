{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, ad, base, bytestring, cereal, constraints
      , containers, criterion, deepseq, hedgehog, hmatrix, lib
      , MonadRandom, mtl, primitive, random, reflection, singletons, text
      , transformers, typelits-witnesses, vector
      }:
      mkDerivation {
        pname = "grenade";
        version = "0.1.0";
        src = ./.;
        libraryHaskellDepends = [
          base bytestring cereal containers deepseq hmatrix MonadRandom
          primitive singletons vector
        ];
        testHaskellDepends = [
          ad base constraints hedgehog hmatrix MonadRandom mtl random
          reflection singletons text transformers typelits-witnesses vector
        ];
        benchmarkHaskellDepends = [ base bytestring criterion hmatrix ];
        description = "Practical Deep Learning in Haskell";
        license = lib.licenses.bsd2;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
