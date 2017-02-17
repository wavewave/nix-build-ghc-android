{ pkgs ? (import <nixpkgs>{}) }:

with pkgs;

let ndkWrapper = import ./ndk-wrapper.nix { inherit stdenv makeWrapper androidndk; };
    hsenv = haskell.packages.ghc7102.ghcWithPackages
      (p: with p;
        [ cabal-install
          hprotoc                  # host protocol buffer code generator
          protocol-buffers         # host protocol buffer library
          aeson
        ]);
    haskell-packages = import ./nixpkgs/top-level/haskell-packages.nix { inherit pkgs callPackage stdenv; };
    ghc-android-env = haskell-packages.packages.ghc-android.ghcWithPackages
      (p: with p;
        [ aeson
          free
          protocol-buffers         # target protocol buffer library
          protocol-buffers-descriptor 
          text-binary
          network-simple
          monad-loops ]);

    protobuf-android = import ./protobuf.nix {inherit protobuf androidndk ndkWrapper;};

    fhs = buildFHSUserEnv {
            name = "android-env";
            targetPkgs = pkgs: with pkgs;
              [ git gitRepo gnupg python2 curl procps openssl gnumake nettools
                androidenv.platformTools androidenv.androidsdk_5_1_1_extras
		androidenv.androidndk 
		jdk schedtool utillinux m4 gperf
                perl libxml2 zip unzip bison flex lzop gradle
		hsenv ghc-android-env ndkWrapper
                protobuf
                pkgconfig
              ];
	    multiPkgs = pkgs: with pkgs; [ zlib  ];
            runScript = "bash";
            profile = ''
              export USE_CCACHE=1
              export JAVA_HOME=${jdk.home}
              export ANDROID_JAVA_HOME=${jdk.home}
	      export ANDROID_HOME=${androidenv.androidsdk_5_1_1_extras}/libexec/android-sdk-linux
	      export ANDROID_NDK_HOME=${androidenv.androidndk}/libexec/${androidenv.androidndk.name}
	      export ANDROID_NDK_ROOT=${androidenv.androidndk}/libexec/${androidenv.androidndk.name}
              export PROTOBUF=${protobuf-android}
              export PKG_CONFIG_PATH=$PROTOBUF/lib/pkgconfig:$PKG_CONFIG_PATH
	    '';
	  };
in stdenv.mkDerivation {
     name = "android-env-shell";
     nativeBuildInputs = [ fhs ];
     buildInputs = [ protobuf-android  ];
     shellHook = "exec android-env";

   }




