#!/usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#source $THIS_DIR/set-env-1.sh
####################################################################################################

# Update config.sub and config.guess
cp -v "$CONFIG_SUB_SRC/config.sub" "$ICONV_SRC/build-aux"
cp -v "$CONFIG_SUB_SRC/config.guess" "$ICONV_SRC/build-aux"
cp -v "$CONFIG_SUB_SRC/config.sub" "$ICONV_SRC/libcharset/build-aux"
cp -v "$CONFIG_SUB_SRC/config.guess" "$ICONV_SRC/libcharset/build-aux"

#apply_patches 'iconv-*' $ICONV_SRC
function apply_patches() {
    pushd $2 > /dev/null
    for p in $(find "$BASEDIR/patches" -name "$1") ; do
        echo Applying patch $p in $(pwd)
        patch -p1 < "$p"
    done
    popd > /dev/null
}

ICONV_SRC=$THIS_DIR/iconv-android
NDK=/nix/store/y48ld9k8svdrr67ncmla8zr80fx821jd-android-ndk-r10c/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
NDK_TARGET=arm-linux-androideabi
BUILD_GCC=/home/wavewave/repo/workspace/ghctest/arm-linux-androideabi-gcc
BUILD_LD=$NDK/bin/$NDK_TARGET-ld
BUILD_ARCH=$($BUILD_GCC -v 2>&1 | grep ^Target: | cut -f 2 -d ' ')
NDK_ADDON_PREFIX=/home/wavewave/repo/workspace/ghctest/usr


# --host=$NDK_TARGET
#--build=$BUILD_ARCH
#--with-build-cc=$BUILD_GCC --with-build-ld=$BUILD_LD 
pushd $ICONV_SRC > /dev/null
CC=$BUILD_GCC LD=$BUILD_LD ./configure --prefix="$NDK_ADDON_PREFIX"   --host=arm \
--enable-static --disable-shared
make $MAKEFLAGS
make install
popd > /dev/null
