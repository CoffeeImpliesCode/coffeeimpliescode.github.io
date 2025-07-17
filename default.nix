# let unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {}; in
{ pkgs ? import <nixpkgs> {}, lib ? pkgs.stdenv.lib }:
  with pkgs;
  mkShell rec {
    buildInputs = [
      zola
      typst typstfmt typst-live tinymist
      nodejs_24 yarn
    ];
    allowUnfree = true;
    # NIXPKGS_ALLOW_UNFREE = 1;
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
    TYPST_IGNORE_SYSTEM_FONTS = true;
    # RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
    # https://github.com/rust-lang/rust-bindgen#environment-variables
    # shellHook = ''
    #   export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
    #   export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
    #   '';
    # Add precompiled library to rustc search path
  }
