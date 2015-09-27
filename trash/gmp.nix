{ stdenv, fetchurl, m4, androidndk, ndkWrapper }: 

stdenv.mkDerivation rec {
  iname = "gmp";
  suffix = "androidndk";
  version = "5.1.3";
  name = iname + "-" + suffix + "-" + version;

  src = fetchurl { # we need to use bz2, others aren't in bootstrapping stdenv
    urls = [ "mirror://gnu/gmp/${iname}-${version}.tar.bz2" "ftp://ftp.gmplib.org/pub/${iname}-${version}/${iname}-${version}.tar.bz2" ];
    sha256 = "0q5i39pxrasgn9qdxzpfbwhh11ph80p57x6hf48m74261d97j83m";
  };

  nativeBuildInputs = [ m4 ndkWrapper ];

  preConfigure = ''
  
    export NDK=${androidndk}/libexec/android-ndk-r10c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
    export NDK_TARGET=arm-linux-androideabi
    export CC=${ndkWrapper}/bin/$NDK_TARGET-gcc
    export LD=${ndkWrapper}/bin/$NDK_TARGET-ld
    export RANLIB=${ndkWrapper}/bin/$NDK_TARGET-gcc-ranlib
    export STRIP=${ndkWrapper}/bin/$NDK_TARGET-strip
    export NM=${ndkWrapper}/bin/$NDK_TARGET-gcc-nm
    export AR=${ndkWrapper}/bin/$NDK_TARGET-gcc-ar
  '';

  configureFlags = [ "--host=arm-linux-androideabi"
                     "--enable-static"
		     "--disable-cxx"
                     "--disable-shared"
		     ];

  buildInputs = [ ];

  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];  


  enableParallelBuilding = true;

  doCheck = false;

}
