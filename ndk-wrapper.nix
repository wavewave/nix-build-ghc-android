{ stdenv, androidndk, makeWrapper }:

stdenv.mkDerivation {
     name = "ndk-wrapper";
     buildInputs = [ makeWrapper ];
     propagatedBuildInputs = [ androidndk ];
     unpackPhase = "true";
     installPhase = ''
       mkdir -p $out/bin
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc $out/bin/arm-linux-androideabi-gcc --add-flags --sysroot=${androidndk}/libexec/android-ndk-r10c/platforms/android-21/arch-arm
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-cpp $out/bin/arm-linux-androideabi-cpp  --add-flags --sysroot=${androidndk}/libexec/android-ndk-r10c/platforms/android-21/arch-arm
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-g++ $out/bin/arm-linux-androideabi-g++  --add-flags --sysroot=${androidndk}/libexec/android-ndk-r10c/platforms/android-21/arch-arm
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ld $out/bin/arm-linux-androideabi-ld
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-strip $out/bin/arm-linux-androideabi-strip       
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc-ar $out/bin/arm-linux-androideabi-gcc-ar
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc-nm $out/bin/arm-linux-androideabi-gcc-nm
       makeWrapper ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc-ranlib $out/bin/arm-linux-androideabi-gcc-ranlib
     '';
   }

#       cat >> $out/bin/arm-linux-androideabi-gcc  << EOF
#       #! ${stdenv.shell}
#       ${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc --sysroot=${androidndk}/libexec/android-ndk-r10c/platforms/android-21/arch-arm \$@
#       EOF
#       chmod +x $out/bin/arm-linux-androideabi-gcc
