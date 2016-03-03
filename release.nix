{ pkgs ? import <nixpkgs> {} }:

with pkgs; 

let haskell-packages = import ./nixpkgs/top-level/haskell-packages.nix { inherit pkgs callPackage stdenv; };
in {
     ghc-android = haskell-packages.compiler.ghc-android
   };
