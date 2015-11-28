{ protobuf, androidndk, ndkWrapper }:

protobuf.overrideDerivation (oldAttr: {
      name = "protobuf-android";
      configureFlags = [ "--host=arm-linux-androideabi" "--with-protoc=true" ];
      buildInputs = oldAttr.buildInputs ++ [ androidndk ndkWrapper ] ;

      preConfigure = ''
        export NDK=${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
        export NDK_TARGET=arm-linux-androideabi
        export CC=${ndkWrapper}/bin/$NDK_TARGET-gcc
        export CXX=${ndkWrapper}/bin/$NDK_TARGET-gcc
        export CXXFLAGS="-I${androidndk}/libexec/android-ndk-r10c/sources/cxx-stl/llvm-libc++/libcxx/include -I${androidndk}/libexec/android-ndk-r10c/sources/android/support/include -I${androidndk}/libexec/android-ndk-r10c/sources/cxx-stl/llvm-libc++abi/libcxxabi/include -std=c++11 -frtti"
        export LD=${ndkWrapper}/bin/$NDK_TARGET-ld
        export LDFLAGS="-L${androidndk}/libexec/android-ndk-r10c/sources/cxx-stl/llvm-libc++/libs/armeabi -lc++_shared -lm"
        export RANLIB=${ndkWrapper}/bin/$NDK_TARGET-gcc-ranlib
        export STRIP=${ndkWrapper}/bin/$NDK_TARGET-strip
        export NM=${ndkWrapper}/bin/$NDK_TARGET-gcc-nm
        export AR=${ndkWrapper}/bin/$NDK_TARGET-gcc-ar
        sed -i -e 's|vector<|std::vector<|' src/google/protobuf/descriptor.h
        sed -i -e 's|vector<|std::vector<|' src/google/protobuf/extension_set_heavy.cc
        sed -i -e 's|vector<|std::vector<|' src/google/protobuf/extension_set.h
        sed -i -e 's|vector<|std::vector<|' src/google/protobuf/unknown_field_set.h
        sed -i -e 's|vector<|std::vector<|' src/google/protobuf/message.h
      '';

      doCheck = false;

    })
