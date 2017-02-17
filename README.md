nix-build-ghc-android
=====================

*NOTE: nixpkgs is a moving target. This nix build has been tested against commit: ce2756f701886313180655a069202f3771621404 (2016-01-19)*


This repo contains nix expressions to build ghc as a cross compiler for android.
This automatically downloads sources for ghc-7.10.2 and android-ndk r10c.
Right now, ghc compiler is built on x86-64 and will run on x86-64 targetting arm devices.

You can start nix-shell by

     nix-shell shell.nix -I nixpkgs=(your nixpkgs directory)

Inside nix-shell, you can run

     arm-unknown-linux-androideabi-ghc test.hs

For recent android, you should make executable binary as position independent executable. To do that, run 

     arm-unknown-linux-androideabi-ghc -fPIC -optl-pie test.hs

cabal can also be easily used.


     cabal --with-ghc=arm-unknown-linux-androideabi-ghc --with-ld=arm-linux-androideabi-ld.gold --with-ghc-pkg=arm-unknown-linux-androideabi-ghc-pkg --ghc-options=-fPIC --ghc-options=-optl-pie configure
     cabal build

Then you can push resultant executable by `adb push` and run it in adb shell. 

Enjoy!

Full Android SDK shell
----------------------

We also have a full android development shell made with `buildFHSUserEnv` to follow conventional filesystem hierarchy. Start the shell by

    nix-shell adb-fhs-shell.nix -I nixpkgs=(your nixpkgs directory)
    


Example
-------

See https://github.com/wavewave/haskell-android-example (this is based on https://github.com/neurocyte/android-haskell-activity but remove foreign-jni dep)


Reference
---------

This work is based on the following works.

* [ghc-android](https://github.com/neurocyte/ghc-android)
* [docker-build-ghc-android](https://github.com/sseefried/docker-build-ghc-android)
* [ghc on android in haskell wiki](https://wiki.haskell.org/Android)
    

