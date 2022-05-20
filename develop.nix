{ pkgs }: with pkgs; let

  ghcCharged =  haskellPackages.ghcWithHoogle (p: with p; [
                  haskell-language-server
                  ghcid
                ]);
  ghcid-bin = haskellPackages.ghcid.bin;

  ghcid-test = let
    ghcid = "${ghcid-bin}/bin/ghcid";
    out = "$out/bin/ghcid-test";
  in runCommand "ghcid-test" { buildInputs = [ makeWrapper ]; } ''
    makeWrapper ${ghcid} ${out} --add-flags "--command='cabal repl test:test-grenade' --test 'Main.main'"
  '';

in mkShell {
  buildInputs =  haskellPackages.grenade.env.nativeBuildInputs ++
                 [ ghcCharged
                   ghcid-bin
                   ghcid-test
                   cabal-install
                   dbus
                   webkitgtk
                   openssl
                 ];
  nativeBuildInputs = with pkgs; [ pkgconfig ];
  dbus = pkgs.dbus;

}
