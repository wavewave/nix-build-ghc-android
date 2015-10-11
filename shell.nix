{ pkgs ? (import <nixpkgs>{}) }:

with pkgs;

let hsenv = haskell.packages.ghc7102.ghcWithPackages
              (p: with p; [cabal-install network-simple monad-loops text-binary ]);

    haskell-packages = import ./nixpkgs/top-level/haskell-packages.nix { inherit pkgs callPackage stdenv; };
    
    ghc-android-env = haskell-packages.packages.ghc-android.ghcWithPackages
                        (p: with p; [network-simple monad-loops text-binary ] ); 
    

    ndkWrapper = import ./ndk-wrapper.nix { inherit stdenv makeWrapper androidndk; };

in stdenv.mkDerivation {
     name = "ghc-android-shell";

     buildInputs = [ hsenv ghc-android-env ndkWrapper ]; 

}