{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      mkPkgs = system: import nixpkgs { inherit system; };

      buildPackage =
        system:
        let
          pkgs = mkPkgs system;

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
            ninja
            valgrind
          ];
        };
    in
    {
      devShell = forAllSystems buildPackage;
    };
}
