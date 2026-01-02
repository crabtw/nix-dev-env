{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      buildPackage =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

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
      devShells = forAllSystems (system: {
        default = buildPackage system;
      });
    };
}
