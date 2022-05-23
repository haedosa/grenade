final: prev: with final; {

  grenade-project = haskell-nix.project {
    src = ./.;
    compiler-nix-name = "ghc884";
    shell.tools = {
      cabal = "latest";
      hlint = "latest";
      haskell-language-server = "latest";
    };
    shell.buildInputs = with final; [

    ];
  };

  # haskellPackages = prev.haskellPackages.override (old: {
  #   overrides = lib.composeManyExtensions (with haskell.lib; [
  #                 (old.overrides or (_: _: {}))
  #                 (self: super: {
  #                   grenade = (grenade-project.flake {}).packages."grenade:lib:grenade";
  #                 })
  #               ]);
  # });

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
