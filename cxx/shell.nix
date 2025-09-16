{
  pkgs ? import <nixpkgs> { },
}:
let
  llvm = pkgs.llvmPackages_latest;

  llvmStdenv = pkgs.overrideCC llvm.libcxxStdenv (
    llvm.libcxxStdenv.cc.override {
      inherit (llvm) bintools;
    }
  );

  myStdenv = llvmStdenv;
  #myStdenv = pkgs.stdenv;
in
pkgs.mkShell.override { stdenv = myStdenv; } {
  packages = with pkgs; [
    cmake
    python3
    ninja
  ];

  buildInputs = with pkgs; [
    zlib
  ];
}
