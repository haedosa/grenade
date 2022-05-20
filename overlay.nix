final: prev: with final; {


  haskellPackages = prev.haskellPackages.override (old: {
    overrides = lib.composeManyExtensions (with haskell.lib; [
                  (old.overrides or (_: _: {}))
                  (self: super: {
                    # formatting = self.formatting_7_1_2;
                    colonnade = doJailbreak (markUnbroken super.colonnade);
                    streaming-utils = doJailbreak (markUnbroken super.streaming-utils);
                  })
                  (packageSourceOverrides { grenade = ./.; })
                ]);
  });

  grenade = haskell.lib.justStaticExecutables haskellPackages.grenade;

  ghcWithgrenade = haskellPackages.ghcWithPackages (p: [ p.grenade ]);

  ghcWithgrenadeAndPackages = select :
    haskellPackages.ghcWithPackages (p: ([ p.grenade ] ++ select p));


  jupyterlab = mkJupyterlab {
    haskellKernelName = "grenade";
    haskellPackages = p: with p;
      [ # add haskell pacakges if necessary
        grenade
        hvega
        ihaskell-hvega
      ];
    pythonKernelName = "grenade";
    pythonPackages = p: with p;
      [ # add python pacakges if necessary
        scipy
        numpy
        tensorflow-bin
        matplotlib
        scikit-learn
        pandas
        lightgbm
      ];
  };
}
