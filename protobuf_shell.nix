{ pkgs ? (import <nixpkgs>{}) }:

with pkgs;

let ndkWrapper = import ./ndk-wrapper.nix { inherit stdenv makeWrapper androidndk; };
    protobuf-android = import ./protobuf.nix { inherit protobuf androidndk ndkWrapper; };
in protobuf-android.overrideDerivation (oldAttr: {
     shellHook = "";
   })

