{ mkDerivation, ad, base, bytestring, cereal, constraints
, containers, criterion, deepseq, hedgehog, hmatrix, lib
, MonadRandom, mtl, primitive, random, reflection, singletons, text
, transformers, typelits-witnesses, vector, stdenv
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
}
