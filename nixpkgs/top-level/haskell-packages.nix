{ pkgs, callPackage, stdenv }:

rec {

  lib = import ../development/haskell-modules/lib.nix { inherit pkgs; };

  compiler = {
    ghc742Binary = callPackage ../development/compilers/ghc/7.4.2-binary.nix ({ gmp = pkgs.gmp4; } // stdenv.lib.optionalAttrs stdenv.isDarwin {
      libiconv = pkgs.darwin.libiconv;
    });
    ghc784 = callPackage ../development/compilers/ghc/7.8.4.nix ({ ghc = compiler.ghc742Binary; } // stdenv.lib.optionalAttrs stdenv.isDarwin {
      libiconv = pkgs.darwin.libiconv;
    });
    ghc7102 = callPackage ../development/compilers/ghc/7.10.2.nix ({ ghc = compiler.ghc784; inherit (packages.ghc784) hscolour; } // stdenv.lib.optionalAttrs stdenv.isDarwin {
      libiconv = pkgs.darwin.libiconv;
    });
    ghc-android = callPackage ../../ghc-android.nix {
      inherit (pkgs) fetchurl haskell makeWrapper autoconf automake llvm_35 ncurses perl;
      #haskell = packages.haskell; 
      inherit stdenv;
      androidndk = pkgs.androidenv.androidndk;
      ghc = compiler.ghc784; 
    };
  };

  packages = {

    ghc784 = callPackage ../development/haskell-modules {
      ghc = compiler.ghc784;
      packageSetConfig = callPackage ../development/haskell-modules/configuration-ghc-7.8.x.nix { };
    };
    ghc7102 = callPackage ../development/haskell-modules {
      ghc = compiler.ghc7102;
      packageSetConfig = callPackage ../development/haskell-modules/configuration-ghc-7.10.x.nix { };
    };
    ghc-android = callPackage ../development/haskell-modules {
      ghc = compiler.ghc-android;
      packageSetConfig = callPackage ../development/haskell-modules/configuration-ghc-7.10.x.nix { };      

    };

  };
}
