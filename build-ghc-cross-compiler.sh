#!/usr/bin/env bash

##  #!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#source $THIS_DIR/set-env-1.sh
####################################################################################################

#cd $NDK_ADDON_SRC
#tar xf ${GHC_TAR_PATH}
#mv ghc-${GHC_RELEASE} "$GHC_SRC"
#apply_patches 'ghc-*' "$GHC_SRC"

BASE_DIR=/home/wavewave/repo/workspace/ghctest

function apply_patches() {
    pushd $2 > /dev/null
    for p in $(find "$BASEDIR/patches" -name "$1") ; do
        echo Applying patch $p in $(pwd)
        patch -p1 < "$p"
    done
    popd > /dev/null
}

GHC_SRC=$THIS_DIR/ghc-7.8.4
GHC_STAGE0=/nix/store/b3p1phyb3qzq8hkplhjnfvxr931fh226-ghc-7.8.4/bin/ghc
NDK=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
NDK_TARGET=arm-linux-androideabi
GHC_PREFIX=/home/wavewave/repo/workspace/ghctest/usr
NDK_ADDON_PREFIX=/home/wavewave/repo/workspace/ghctest/usr

pushd "$GHC_SRC" > /dev/null



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
CONF_CC_OPTS_STAGE1 =  -fno-stack-protector --sysroot=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/platforms/android-21/arch-arm
libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-libraries=/nix/store/84bj0jv0483sdz5zhq2a13kf99slrskh-gmp-5.1.3/lib
libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-includes=/nix/store/84bj0jv0483sdz5zhq2a13kf99slrskh-gmp-5.1.3/include
libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-includes=/home/wavewave/repo/workspace/ghctest/usr/include
libraries/terminfo_CONFIGURE_OPTS += --configure-option=--with-curses-libraries=/home/wavewave/repo/workspace/ghctest/usr/lib
libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-includes=/home/wavewave/repo/workspace/ghctest/usr/include 
libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-libraries=/home/wavewave/repo/workspace/ghctest/usr/lib
EOF

#libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-includes=/nix/store/qlxp7vb63fp8kx5vk9a0y3rj8svbvl27-glibc-2.21/include
#libraries/base_CONFIGURE_OPTS += --configure-option=--with-iconv-libraries=/nix/store/qlxp7vb63fp8kx5vk9a0y3rj8svbvl27-glibc-2.21/lib

# Update config.sub and config.guess
for x in $(find . -name "config.sub") ; do
    dir=$(dirname $x)
    cp -v "$CONFIG_SUB_SRC/config.sub" "$dir"
    cp -v "$CONFIG_SUB_SRC/config.guess" "$dir"
done

# Apply library patches
apply_patches "hsc2hs-*" "$GHC_SRC/utils/hsc2hs"
apply_patches "haskeline-*" "$GHC_SRC/libraries/haskeline"
apply_patches "unix-*" "$GHC_SRC/libraries/unix"
apply_patches "base-*" "$GHC_SRC/libraries/base"

# Configure
perl boot
#CFLAGS=--sysroot=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/platforms/android-21/arch-arm
# "$NDK/bin/$NDK_TARGET-gcc --sysroot=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/platforms/android-21/arch-arm"
./configure --enable-bootstrap-with-devel-snapshot --prefix="$GHC_PREFIX" --target=$NDK_TARGET \
	    --with-ghc=$GHC_STAGE0 --with-gcc=/home/wavewave/repo/workspace/ghctest/arm-linux-androideabi-gcc --with-ld=$NDK/bin/$NDK_TARGET-ld \
	    --with-nm=$NDK/bin/$NDK_TARGET-gcc-nm --with-ar=$NDK/bin/$NDK_TARGET-gcc-ar --with-ranlib=$NDK/bin/$NDK_TARGET-gcc-ranlib

function check_install_gmp_constants() {
    GMPDCHDR="libraries/integer-gmp/mkGmpDerivedConstants/dist/GmpDerivedConstants.h"
    if ! [ -e  "$GMPDCHDR" ] ; then
        if [ -e "$BASEDIR/patches/gmp-$NDK_DESC-GmpDerivedConstants.h" ] ; then
            cp -v "$BASEDIR/patches/gmp-$NDK_DESC-GmpDerivedConstants.h" "$GMPDCHDR"
        else
            echo \#\#\# Execute the following commands to generate a GmpDerivedConstants.h for your target, then run build again:
            echo \#\#\# adb push ghc-$NDK_DESC/libraries/integer-gmp/cbits/mkGmpDerivedConstants /data/local
            echo \#\#\# adb shell /data/local/mkGmpDerivedConstants \> $BASEDIR/patches/gmp-$NDK_DESC-GmpDerivedConstants.h
            echo \#\#\# adb shell rm /data/local/mkGmpDerivedConstants
            exit 1
        fi
    fi
}

make $MAKEFLAGS || true # TMP hack, see http://hackage.haskell.org/trac/ghc/ticket/7490
make $MAKEFLAGS || true # TMP hack, target mkGmpDerivedConstants fails on build host
# There's a long pause at this point. Just be patient!
check_install_gmp_constants
make $MAKEFLAGS || true # TMP hack, tries to execut inplace stage2
make $MAKEFLAGS || true # TMP hack, one more for luck
make install


