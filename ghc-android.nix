#{ pkgs ? (import <nixpkgs>{}) }:
{ stdenv, fetchurl, makeWrapper, perl, m4, autoconf, automake
, llvm_35, haskell, ncurses
, androidndk
}:

let hsenv = haskell.packages.ghc784.ghcWithPackages (p: with p; [ happy alex ]);
    ndkWrapper = import ./ndk-wrapper.nix { inherit stdenv makeWrapper androidndk; };
    ncurses_ndk = import ./ncurses.nix { inherit stdenv fetchurl ncurses ndkWrapper androidndk; };
    libiconv_ndk = import ./libiconv.nix { inherit stdenv fetchurl ndkWrapper androidndk; };
    gmp_ndk = import ./gmp.nix { inherit stdenv fetchurl m4;
                                 inherit ndkWrapper androidndk;
                               };
in stdenv.mkDerivation {
     name = "ghc-android";
     version = "7.10.2";

     src = fetchurl {
       url = "https://downloads.haskell.org/~ghc/7.10.2/ghc-7.10.2-src.tar.xz";
       sha256 = "1x8m4rp2v7ydnrz6z9g8x7z3x3d3pxhv2pixy7i7hkbqbdsp7kal";
     };
     

     buildInputs = [ hsenv
                     perl
                     llvm_35
                     ndkWrapper
                     androidndk 
		     m4 autoconf automake
		     ncurses_ndk libiconv_ndk
		     #gmp_ndk
		     ncurses
		     #gmp 
                   ];
     patches = [ ./unix-posix_vdisable.patch
                 ./unix-posix-files-imports.patch
		 ./enable-fPIC.patch
		 ./no-pthread-android.patch
               ];

     preConfigure = ''
cat > mk/build.mk <<EOF
BuildFlavour = quick-cross
SRC_HC_OPTS = -H64m -O0
GhcStage1HcOpts = -O -fPIC
GhcStage2HcOpts = -O0 -fPIC -fllvm
SplitObjs = NO
Stage1Only = YES
DYNAMIC_BY_DEFAULT = NO
DYNAMIC_GHC_PROGRAMS=NO
HADDOCK_DOCS = NO
BUILD_DOCBOOK_HTML = NO
BUILD_DOCBOOK_PS   = NO
BUILD_DOCBOOK_PDF  = NO
INTEGER_LIBRARY = integer-simple
GhcHcOpts = -Rghc-timing
#GhcLibWays += p
GhcLibWays = v thr p
#v thr
libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-includes=${libiconv_ndk}/include 
libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-libraries=${libiconv_ndk}/lib
libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-includes=${ncurses_ndk}/include
libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-libraries=${ncurses_ndk}/lib
EOF
perl boot
     '';
     
     configureFlags = [
       "--target=arm-linux-androideabi"
       "--host=x86_64-unknown-linux-gnu"
       "--build=x86_64-unknown-linux-gnu"
       "--with-gcc=${ndkWrapper}/bin/arm-linux-androideabi-gcc"
       "--with-gmp-includes=${gmp_ndk}/include" "--with-gmp-libraries=${gmp_ndk}/lib"
     ];

     phases = [ "unpackPhase" "patchPhase" "configurePhase" "buildPhase" "installPhase" ];

     enableParallelBuilding = true;

     #shellHook = ''
     #  export PATH=${ndkWrapper}/bin:$PATH
     #  export NIX_GHC="${hsenv}/bin/ghc"
     #  export NIX_GHCPKG="${hsenv}/bin/ghc-pkg"
     #  export NIX_GHC_DOCDIR="${hsenv}/share/doc/ghc/html"
     #  export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
     #'';

     meta.license = stdenv.lib.licenses.bsd3;
     meta.platforms = ["x86_64-linux" "i686-linux" "x86_64-darwin"];

   }

