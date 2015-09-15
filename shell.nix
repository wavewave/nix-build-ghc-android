{ pkgs ? (import <nixpkgs>{}) }:

let hsenv = pkgs.haskell.packages.ghc784.ghcWithPackages (p: with p; []);
in pkgs.stdenv.mkDerivation {
     name = "ghc-android";
     buildInputs = with pkgs; [ hsenv
                                androidenv.androidndk 
		                m4 autoconf automake
				ncurses gmp libiconv
                              ];
     shellHook = ''
       export ICONV=${pkgs.libiconv}
       export PATH=${pkgs.androidenv.androidndk}//libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
       export NIX_GHC="${hsenv}/bin/ghc"
       export NIX_GHCPKG="${hsenv}/bin/ghc-pkg"
       export NIX_GHC_DOCDIR="${hsenv}/share/doc/ghc/html"
       export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
     '';
   }

#     fhs = pkgs.buildFHSUserEnv {
#       name = "android-env";
#       targetPkgs = pkgs: with pkgs;
#                    [ git gitRepo gnupg python2 curl procps openssl gnumake nettools
#                      androidenv.platformTools androidenv.androidsdk_5_1_1
#          	     androidenv.androidndk
# 		     jdk schedtool utillinux m4 autoconf automake gperf
#                      perl libxml2 zip unzip bison flex lzop gradle hsenv
#                      ncurses
#                    ];
#       multiPkgs  = pkgs: with pkgs; [ zlib ];
#       runScript = "bash";
#       profile = ''
#         export USE_CCACHE=1
#         export ANDROID_JAVA_HOME=${pkgs.jdk.home}
#         export ANDROID_HOME=${pkgs.androidenv.androidsdk_5_1_1}/libexec/android-sdk-linux
#         export ANDROID_NDK_HOME=${pkgs.androidenv.androidndk}/libexec/android-ndk-r10c
#         export ANDROID_NDK_ROOT=${pkgs.androidenv.androidndk}/libexec/android-ndk-r10c
#         export NIX_GHC="${hsenv}/bin/ghc"
#         export NIX_GHCPKG="${hsenv}/bin/ghc-pkg"
#         export NIX_GHC_DOCDIR="${hsenv}/share/doc/ghc/html"
#         export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
	
#       '';
#       };
# in  pkgs.stdenv.mkDerivation {
#       name = "android-env-shell";
#       nativeBuildInputs = [ fhs ];
#       shellHook = "exec android-env";
#     } 
