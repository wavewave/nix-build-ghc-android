{ pkgs ? (import <nixpkgs>{}) }:

let hsenv = pkgs.haskell.packages.ghc784.ghcWithPackages (p: with p; []);
    ndkWrapper = import ./ndk-wrapper.nix { inherit (pkgs) stdenv makeWrapper;
                                            androidndk = pkgs.androidenv.androidndk; };
    ncurses_ndk = import ./ncurses.nix { inherit (pkgs) stdenv fetchurl ncurses; inherit ndkWrapper ;
                                         androidndk = pkgs.androidenv.androidndk; };
    libiconv_ndk = import ./libiconv.nix { inherit (pkgs) stdenv fetchurl; inherit ndkWrapper;
                                           androidndk = pkgs.androidenv.androidndk; };
    buildGHCsh = with pkgs; writeScript "build-ghc-android.sh" ''
#! ${stdenv.shell}
     
# Setup build.mk
cat > mk/build.mk <<EOF
Stage1Only = YES
DYNAMIC_GHC_PROGRAMS = NO
SRC_HC_OPTS     = -O -H64m
GhcStage1HcOpts = -O2 -fasm
GhcStage2HcOpts = -O2 -fasm $ARCH_OPTS
GhcHcOpts       = -Rghc-timing
GhcLibHcOpts    = -O2
GhcLibWays      = v
HADDOCK_DOCS       = NO
BUILD_DOCBOOK_HTML = NO
BUILD_DOCBOOK_PS   = NO
BUILD_DOCBOOK_PDF  = NO
EOF
export GHC_PREFIX=/home/wavewave/repo/workspace/ghctest/usr
perl boot
 

./configure --enable-bootstrap-with-devel-snapshot --prefix="$GHC_PREFIX" --target=arm-linux-androideabi \
	    --with-ghc=${hsenv}/bin/ghc --with-gcc=${ndkWrapper}/bin/arm-linux-androideabi-gcc \
	    --with-ld=${ndkWrapper}/bin/arm-linux-androideabi-ld \
	    --with-nm=${ndkWrapper}/bin/arm-linux-androideabi-gcc-nm \
	    --with-ar=${ndkWrapper}/bin/arm-linux-androideabi-gcc-ar \
	    --with-ranlib=${ndkWrapper}/bin/arm-linux-androideabi-gcc-ranlib
'';

in pkgs.stdenv.mkDerivation {
     inherit buildGHCsh;
     name = "ghc-android";

     src = pkgs.fetchurl {
       url = "http://www.haskell.org/ghc/dist/7.8.4/ghc-7.8.4-src.tar.xz";
       sha256 = "1i4254akbb4ym437rf469gc0m40bxm31blp6s1z1g15jmnacs6f3";
     };

     buildInputs = with pkgs; [ hsenv
                                ndkWrapper
                                androidenv.androidndk 
		                m4 autoconf automake
				ncurses_ndk libiconv_ndk
				ncurses
				gmp 
                              ];
     shellHook = ''
       #eval $buildGHCsh
       export ICONV=${pkgs.libiconv}
       export PATH=${pkgs.androidenv.androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
       export NIX_GHC="${hsenv}/bin/ghc"
       export NIX_GHCPKG="${hsenv}/bin/ghc-pkg"
       export NIX_GHC_DOCDIR="${hsenv}/share/doc/ghc/html"
       export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
     '';
   }

# ./configure --target=arm-linux-androideabi  --host=x86_64-unknown-linux-gnu --build=x86_64-unknown-linux-gnu --with-gcc=gcc


      #libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-libraries=/nix/store/84bj0jv0483sdz5zhq2a13kf99slrskh-gmp-5.1.3/lib
      # libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-includes=/nix/store/84bj0jv0483sdz5zhq2a13kf99slrskh-gmp-5.1.3/include

#export CC=${ndkWrapper}/bin/$NDK_TARGET-gcc
#export LD=${ndkWrapper}/bin/$NDK_TARGET-ld
#export RANLIB=${ndkWrapper}/bin/$NDK_TARGET-gcc-ranlib
#export STRIP=${ndkWrapper}/bin/$NDK_TARGET-strip
#export NM=${ndkWrapper}/bin/$NDK_TARGET-gcc-nm
#export AR=${ndkWrapper}/bin/$NDK_TARGET-gcc-ar


#CONF_CC_OPTS_STAGE1 =  -fno-stack-protector

#libraries/terminfo_CONFIGURE_OPTS = --configure-option=--with-compiler=ghc
#libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-cc=${ndkWrapper}/bin/arm-linux-androideabi-gcc
#libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-ld=${ndkWrapper}/bin/arm-linux-androideabi-ld
#libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-includes=${ncurses_ndk}/include
#libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-libraries=${ncurses_ndk}/lib

#libraries/base_CONFIGURE_OPTS += --configure-option=--with-ld=${ndkWrapper}/bin/arm-linux-androideabi-ld
#libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-includes=${libiconv_ndk}/include 
#libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-libraries=${libiconv_ndk}/lib
