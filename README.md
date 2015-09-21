nix-build-ghc-android
=====================

This repo contains nix expressions to build ghc as a cross compiler for android.
This automatically downloads sources for ghc-7.10.2 and android-ndk r10c.
Right now, ghc compiler is built on x86-64 and will run on x86-64 targetting arm devices.

You can start nix-shell by

     nix-shell shell.nix -I nixpkgs=(your nixpkgs directory)

Inside nix-shell, you can run

     arm-unknown-linux-androideabi-ghc test.hs

For recent android, you should make executable binary as position independent executable. To do that, run 

     arm-unknown-linux-androideabi-ghc -fPIC -optl-pie test.hs

Enjoy!



