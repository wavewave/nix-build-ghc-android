{ pkgs ? (import <nixpkgs>{}) }:

with pkgs;

let ndkWrapper = import ./ndk-wrapper.nix { inherit stdenv makeWrapper androidndk; };
    ghc-android = import ./ghc-android.nix
                    { inherit stdenv fetchurl makeWrapper perl m4 autoconf automake llvm_35 haskell ncurses;
                      androidndk = androidenv.androidndk; };
    hsenv = haskell.packages.ghc7102.ghcWithPackages (p: with p; [cabal-install]);

    fhs = buildFHSUserEnv {
            name = "android-env";
            targetPkgs = pkgs: with pkgs;
              [ git gitRepo gnupg python2 curl procps openssl gnumake nettools
                androidenv.platformTools androidenv.androidsdk_5_1_1
		androidenv.androidndk
		jdk schedtool utillinux m4 gperf
                perl libxml2 zip unzip bison flex lzop gradle
		hsenv ghc-android ndkWrapper
              ];
	    multiPkgs = pkgs: with pkgs; [ zlib ];
            runScript = "bash";
            profile = ''
              export USE_CCACHE=1
              export ANDROID_JAVA_HOME=${jdk.home}
	      export ANDROID_HOME=${androidenv.androidsdk_5_1_1}/libexec/android-sdk-linux
	      export ANDROID_NDK_HOME=${androidenv.androidndk}/libexec/android-ndk-r10c
	      export ANDROID_NDK_ROOT=${androidenv.androidndk}/libexec/android-ndk-r10c	      
	    '';
	  };
in stdenv.mkDerivation {
     name = "android-env-shell";
     nativeBuildInputs = [ fhs ];
     shellHook = "exec android-env";

   }




