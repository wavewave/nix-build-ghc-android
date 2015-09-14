#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#source $THIS_DIR/set-env-1.sh
####################################################################################################

NCURSES_SRC=/home/wavewave/repo/workspace/ghctest/ncurses-5.9
NDK_ADDON_PREFIX=/home/wavewave/repo/workspace/ghctest/usr
NDK=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
NDK_TARGET=arm-linux-androideabi
BUILD_GCC=$NDK/bin/$NDK_TARGET-gc
BUILD_ARCH=arm-linux-androideabi


pushd $NCURSES_SRC > /dev/null
./configure --prefix="$NDK_ADDON_PREFIX" --host=$NDK_TARGET --build=$BUILD_ARCH --with-build-cc=$BUILD_GCC --enable-static --disable-shared --includedir="$NDK_ADDON_PREFIX/include" --without-manpages
echo '#undef HAVE_LOCALE_H' >> "$NCURSES_SRC/include/ncurses_cfg.h"   # TMP hack
make $MAKEFLAGS
make install
popd > /dev/null
