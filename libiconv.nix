{ stdenv, fetchurl, androidndk, ndkWrapper }: 

stdenv.mkDerivation rec {
  iname = "libiconv";
  version = "1.14";
  suffix = "androidndk";
  name = iname + "-" + suffix + "-" + version;
  
  src = fetchurl {
    url = "mirror://gnu/libiconv/${iname}-${version}.tar.gz";
    sha256 = "04q6lgl3kglmmhw59igq1n7v3rp1rpkypl366cy1k1yn2znlvckj";
  };

  # gcc-5.patch should be removed after 5.9
  # patches = [ ./clang.patch ./gcc-5.patch ];

  configureFlags = [ "--host=arm"
                     "--enable-static"
                     "--disable-shared"
                     "--without-manpages"
                     "--without-debug"
		     "--without-cxx" ];

  buildInputs = []; 
  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];
  preConfigure = ''
    export NDK=${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
    export NDK_TARGET=arm-linux-androideabi
    export CC=${ndkWrapper}/bin/$NDK_TARGET-gcc
    export LD=${ndkWrapper}/bin/$NDK_TARGET-ld
    export RANLIB=${ndkWrapper}/bin/$NDK_TARGET-gcc-ranlib
    export STRIP=${ndkWrapper}/bin/$NDK_TARGET-strip
    export NM=${ndkWrapper}/bin/$NDK_TARGET-gcc-nm
    export AR=${ndkWrapper}/bin/$NDK_TARGET-gcc-ar
    ##export PKG_CONFIG_LIBDIR="$out/lib/pkgconfig"
    ##mkdir -p "$PKG_CONFIG_LIBDIR"
  '';

  enableParallelBuilding = true;

  doCheck = false;

  #fixUpPhase = ''
  #  exit -1
  #''; #true;


  #passthru = {
  #  ldflags = "-lncurses";
  #  inherit unicode abiVersion;
  #};
}


                     # "--with-build-cc=${ndkWrapper}/bin/arm-linux-androideabi-gcc"
		     # "--with-build-cpp=${ndkWrapper}/bin/arm-linux-androideabi-cpp"
