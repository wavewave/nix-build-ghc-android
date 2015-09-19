{ pkgs ? (import <nixpkgs>{}) }:

let hsenv = pkgs.haskell.packages.ghc784.ghcWithPackages (p: with p; []);
    ndkWrapper = import ./ndk-wrapper.nix { inherit (pkgs) stdenv makeWrapper;
                                            androidndk = pkgs.androidenv.androidndk; };
    ncurses_ndk = import ./ncurses.nix { inherit (pkgs) stdenv fetchurl ncurses; inherit ndkWrapper ;
                                         androidndk = pkgs.androidenv.androidndk; };
    libiconv_ndk = import ./libiconv.nix { inherit (pkgs) stdenv fetchurl; inherit ndkWrapper;
                                           androidndk = pkgs.androidenv.androidndk; };
in with pkgs; stdenv.mkDerivation {
     #inherit buildGHCsh;
     name = "ghc-android";
     #src = pkgs.fetchurl {
     #  url = "http://www.haskell.org/ghc/dist/7.8.4/ghc-7.8.4-src.tar.xz";
     #  sha256 = "1i4254akbb4ym437rf469gc0m40bxm31blp6s1z1g15jmnacs6f3";
     #};

     src = fetchurl {
       url = "https://downloads.haskell.org/~ghc/7.10.2/ghc-7.10.2-src.tar.xz";
       sha256 = "1x8m4rp2v7ydnrz6z9g8x7z3x3d3pxhv2pixy7i7hkbqbdsp7kal";
     };
     

     buildInputs = [ hsenv
                     ndkWrapper
                     androidenv.androidndk 
		     m4 autoconf automake
		     ncurses_ndk libiconv_ndk
		     ncurses
		     gmp 
                   ];

     preConfigure = ''
cat > mk/build.mk <<EOF
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
       #"--with-gcc=${stdenv.cc}/bin/cc"
       #"--with-gmp-includes=${gmp}/include" "--with-gmp-libraries=${gmp}/lib"
     ];
			      
     shellHook = ''
       export ICONV=${libiconv}
       #export PATH=${androidenv.androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
       export PATH=${ndkWrapper}/bin:$PATH
       export NIX_GHC="${hsenv}/bin/ghc"
       export NIX_GHCPKG="${hsenv}/bin/ghc-pkg"
       export NIX_GHC_DOCDIR="${hsenv}/share/doc/ghc/html"
       export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
     '';
   }

# ./configure --target=arm-linux-androideabi  --host=x86_64-unknown-linux-gnu --build=x86_64-unknown-linux-gnu --with-gcc=gcc

       #eval $buildGHCsh

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
