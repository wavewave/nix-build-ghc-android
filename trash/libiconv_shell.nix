{ pkgs ? (import <nixpkgs>{}) }:

let hsenv = pkgs.haskell.packages.ghc784.ghcWithPackages (p: with p; []);
    ndkWrapper = import ./ndk-wrapper.nix { inherit (pkgs) stdenv makeWrapper;
                                            androidndk = pkgs.androidenv.androidndk; };
    ncurses_ndk = import ./ncurses.nix { inherit (pkgs) stdenv fetchurl; inherit ndkWrapper ;
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
CONF_CC_OPTS_STAGE1 =  -fno-stack-protector 
libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-includes=${ncurses_ndk}/include
libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-libraries=${ncurses_ndk}/lib
libraries/base_CONFIGURE_OPTS += --configure-option=--with-ld=${ndkWrapper}/bin/arm-linux-androideabi-ld
libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-includes=${libiconv_ndk}/include 
libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-libraries=${libiconv_ndk}/lib
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

in libiconv_ndk
